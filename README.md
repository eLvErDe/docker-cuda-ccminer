# nvidia-docker image for Tpruvot CCMiner (CUDA)

This image uses [Tpruvot CCMiner] from my own [Debian/Ubuntu mining packages repository].
It requires a CUDA compatible docker implementation so you should probably go
for [nvidia-docker].
It has also been tested successfully on [Mesos] 1.2.1.

## Build images

```
git clone https://github.com/EarthLab-Luxembourg/docker-cuda-ccminer
cd docker-cuda-ccminer
docker build -t cuda-ccminer .
```

## Publish it somewhere

```
docker tag cuda-ccminer docker.domain.com/mining/cuda-ccminer
docker push docker.domain.com/mining/cuda-ccminer
```

## Test it (using dockerhub published image)

```
nvidia-docker pull earthlablux/cuda-ccminer:latest
nvidia-docker run -it --rm earthlablux/cuda-ccminer /usr/bin/ccminer --help
```

An example command line to mine Groestl on MiningPoolHub (ccminer supports nearly all algorythm so check its documentation and picks what you want):
```
nvidia-docker run -it --rm --name cuda-grs-ccminer earthlablux/cuda-ccminer /usr/bin/ccminer -a groestl -o stratum+tcp://europe1.groestlcoin.miningpoolhub.com:20486 -u acecile.catch-all -x 1 --failover-only -o us-east1.groestlcoin.miningpoolhub.com:20486 -u acecile.catch-all -p x 
```

Ouput will looks like:
```
```


## Background job running forever

```
nvidia-docker run -dt --restart=always --name cuda-grs-ccminer earthlablux/cuda-ccminer /usr/bin/ccminer -a groestl -o stratum+tcp://europe1.groestlcoin.miningpoolhub.com:20486 -u acecile.catch-all -x 1 --failover-only -o us-east1.groestlcoin.miningpoolhub.com:20486 -u acecile.catch-all -p x
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
```

[Tpruvot CCMiner]: https://github.com/tpruvot/ccminer
[Debian/Ubuntu mining packages repository]: https://packages.le-vert.net/mining/
[nvidia-docker]: https://github.com/NVIDIA/nvidia-docker
[Mesos]: http://mesos.apache.org/documentation/latest/gpu-support/
