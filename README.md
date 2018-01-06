# nvidia-docker image for Tpruvot CCMiner (CUDA)

This image uses [Tpruvot CCMiner] from my own [Debian/Ubuntu mining packages repository].
It requires a CUDA compatible docker implementation so you should probably go
for [nvidia-docker].
It has also been tested successfully on [Mesos] 1.2.1.

## compute52 - cuda9 variants

According to [djm34] Lyra2Z (at least) is way faster if CUDA compute level is limited to 5.2 instead of enable all features for recents CPUs.

So in my mining packages repository, I provide two flavors of ccminer-tpruvot packages.
The second one is ccminer-tpruvot-compute52 that can be turned into a CUDA docker image by building Dockerfile.compute52 (see below).

For instance, here are a few benchmarks when mining Zcoin (XZC) zith cuda-ccminer or cuda-ccminer-compute52 images:

|                          | cuda-ccminer | cuda-ccminer-compute52 |
|--------------------------|--------------|------------------------|
| GTX1070                  | 1275 kH/s    | 1496 kH/s              |
| GTX1080                  | 1593 kH/s    | 1871 kH/s              |
| GTX1080 (another)        | 1651 kH/s    | 1932 kH/s              |
| GTX1080Ti (PwrLimit 200) | 2352 kH/s    | 2746 kH/s              |

Speaking about Lyra2Z, please run ccminer with `--submit-stale` otherwise you will loose nearly half of your hashrate !

Also, if you are running NVIDIA driver >= 384.81, you can use CUDA 9 variants :-)
It's usually faster:

|                              | GTX1080 / XZC |
|------------------------------|---------------|
| Regular build (CUDA 8)       | 1634 kH/s     |
| CUDA level 5.2 only (CUDA 8) | 1915 kH/s     |
| Regular build (CUDA 9)       | 2151 kH/s     |
| UDA level 5.2 only (CUDA 9)  | 2153 kH/s     |

This is probably highly related to the cypher, in the example above you can see there was clearly something wrong for this crypto with compute level > 5.2. The "bug" has been fixed in CUDA 9 which, by the way, give an additional hashrate boost.

I'd be very happy to add your own hashrates here if you do some testing !


## Build images

```
git clone https://github.com/eLvErDe/docker-cuda-ccminer
cd docker-cuda-ccminer
docker build -t cuda-ccminer .
docker build . -t cuda-ccminer-compute52 -f Dockerfile.compute52
docker build . -t cuda-ccminer-cuda9 -f Dockerfile.cuda9
docker build . -t cuda-ccminer-cuda9-compute52 -f Dockerfile.cuda9.compute52

```

## Publish it somewhere

```
docker tag cuda-ccminer docker.domain.com/mining/cuda-ccminer
docker push docker.domain.com/mining/cuda-ccminer

```

## Test it (using dockerhub published image)

```
nvidia-docker pull acecile/cuda-ccminer:latest
nvidia-docker run -it --rm acecile/cuda-ccminer /usr/bin/ccminer --help
```

An example command line to mine Groestl on MiningPoolHub (ccminer supports nearly all algorythm so check its documentation and picks what you want):
```
nvidia-docker run -it --rm -p 4068:4068 --name cuda-grs-ccminer acecile/cuda-ccminer /usr/bin/ccminer -a groestl -o stratum+tcp://europe1.groestlcoin.miningpoolhub.com:20486 -u acecile.catch-all -p x --api-bind=0.0.0.0:4068 --api-allow=0/0
```

Ouput will looks like:
```
*** ccminer 2.2.3 for nVidia GPUs by tpruvot@github ***
    Built with the nVidia CUDA Toolkit 8.0 64-bits

  Originally based on Christian Buchner and Christian H. project
  Include some kernels from alexis78, djm34, djEzo, tsiv and krnlx.

BTC donation address: 1AJdfCpLWPNoAMDfHF1wD5y8VgKSSTHxPo (tpruvot)

[2017-12-05 23:15:44] 1 miner thread started, using 'groestl' algorithm.
[2017-12-05 23:15:44] Starting on stratum+tcp://europe1.groestlcoin.miningpoolhub.com:20486
[2017-12-05 23:15:44] Stratum difficulty set to 5 (0.01953)
[2017-12-05 23:15:44] GPU #0: Intensity set to 19, 524288 cuda threads
[2017-12-05 23:15:45] API open in full access mode to 0/0 on port 4068
[2017-12-05 23:15:49] GPU #0: GeForce GTX 1080 Ti, 26.08 MH/s
[2017-12-05 23:15:51] accepted: 1/1 (diff 0.036), 26.51 MH/s yes!
[2017-12-05 23:16:03] GPU #0: GeForce GTX 1080 Ti, 26.60 MH/s
[2017-12-05 23:16:03] accepted: 2/2 (diff 0.065), 26.55 MH/s yes!
[2017-12-05 23:16:04] accepted: 3/3 (diff 0.069), 26.58 MH/s yes!
```


## Background job running forever

```
nvidia-docker run -dt --restart=unless-stopped -p 4068:4068 --name cuda-grs-ccminer acecile/cuda-ccminer /usr/bin/ccminer -a groestl -o stratum+tcp://europe1.groestlcoin.miningpoolhub.com:20486 -u acecile.catch-all -p x --api-bind=0.0.0.0:4068 --api-allow=0/0
```

You can check the output using `docker logs cuda-grs-ccminer -f` 


## Use it with Mesos/Marathon

Edit `mesos_marathon.json` to replace miner parameter, change application path as well as docker image address (if you dont want to use public docker image provided).
Then simply run (adapt application name here too):

```
curl -X PUT -u marathon\_username:marathon\_password --header 'Content-Type: application/json' "http://marathon.domain.com:8080/v2/apps/mining/cuda-ccminer?force=true" -d@./mesos\_marathon.json
```

You can check CUDA usage on the mesos slave (executor host) by running `nvidia-smi` there:

```
Wed Dec  6 00:21:09 2017       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 375.82                 Driver Version: 375.82                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX 108...  On   | 0000:82:00.0     Off |                  N/A |
| 51%   67C    P2   197W / 200W |   1729MiB / 11172MiB |     98%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID  Type  Process name                               Usage      |
|=============================================================================|
|    0     21474    C   /usr/bin/ccminer                              1729MiB |
+-----------------------------------------------------------------------------+
```

[Tpruvot CCMiner]: https://github.com/tpruvot/ccminer
[Debian/Ubuntu mining packages repository]: https://packages.le-vert.net/mining/
[nvidia-docker]: https://github.com/NVIDIA/nvidia-docker
[Mesos]: http://mesos.apache.org/documentation/latest/gpu-support/
[djm34]: https://github.com/djm34/ccminer-msvc2015/releases
