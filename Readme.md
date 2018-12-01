# SFM notes

### Build the Docker images

```bash
cd openmvg-docker && docker build . -t spikeheap/openmvg
cd ../openmvs-docker && docker build . -t spikeheap/openmvs
cd ..
```

### Create your project directory

```bash
PROJECT=2017-02_dji_driveway
mkdir projects/${PROJECT}/images/
```

Then drop your source images into that directory

### Resize the images (optional)

> You may not need to do this if you don't have a tonne of images

```bash
cd projects/${PROJECT}/images/
for file in projects/${PROJECT}/originals/*; do convert $file -resize 1500x1500\> projects/${PROJECT}/images/`basename $file`; done
```

### Run for a set of images

```bash
PROJECT=2017-02_dji_driveway

mkdir -p projects/${PROJECT}/out/openMVS

alias dmvg="docker run --rm -it -v /Volumes/Twilight/Users/rb/src/sfm/:/work spikeheap/openmvg"

dmvg openMVG_main_SfMInit_ImageListing  -i /work/projects/${PROJECT}/images -o /work/projects/${PROJECT}/out/matches -d /openMVG/src/openMVG/exif/sensor_width_database/sensor_width_camera_database.txt

dmvg openMVG_main_ComputeFeatures  -i /work/projects/${PROJECT}/out/matches/sfm_data.json -o /work/projects/${PROJECT}/out/matches

dmvg openMVG_main_ComputeMatches  -i /work/projects/${PROJECT}/out/matches/sfm_data.json -o /work/projects/${PROJECT}/out/matches

dmvg openMVG_main_IncrementalSfM  -i /work/projects/${PROJECT}/out/matches/sfm_data.json -m /work/projects/${PROJECT}/out/matches -o  /work/projects/${PROJECT}/out/

#dmvg openMVG_main_openMVG2openMVS -i /work/projects/${PROJECT}/out/matches/sfm_data.json -d /work/projects/${PROJECT}/out/openMVS -o /work/projects/${PROJECT}/out/openMVS/scene.mvs

dmvg openMVG_main_openMVG2openMVS -i /work/projects/${PROJECT}/out/sfm_data.bin -o /work/projects/${PROJECT}/out/openMVS/scene.mvs

# Then we move on to openMVS

alias dmvs="docker run --rm -it -v /Volumes/Twilight/Users/rb/src/sfm/:/work spikeheap/openmvs"

dmvs DensifyPointCloud /work/projects/picnic_bench/out/openMVS/scene.mvs

dmvs ReconstructMesh /work/projects/picnic_bench/out/openMVS/scene_dense.mvs

dmvs RefineMesh /work/projects/picnic_bench/out/openMVS/scene_dense_mesh.mvs

dmvs TextureMesh /work/projects/picnic_bench/out/openMVS/scene_dense_mesh.mvs
```

From https://github.com/openMVG/openMVG/issues/63#issuecomment-129561046:

> Yes, openMVG_main_CreateList has been renamed into main_SfMInit_ImageListing.
> 
> Now the steps are:
> 1/ main_SfMInit_ImageListing
> 2/ main_ComputeFeatures
> 3/ main_ComputeMatches
> 4/ main_IncrementalSfM


# Extracting from video

PROJECT=/Volumes/Twilight/Users/rb/Desktop/sfm/projects/dinorwic/
```bash
PROJECT=/Volumes/Twilight/Users/rb/Desktop/sfm/projects/kerry
VIDEO_SRC=${PROJECT}/source_video/DJI_0018.MOV
DEST_IMAGES=${PROJECT}/images/img_%d.png
ffmpeg -i ${VIDEO_SRC} -f image2 -vf fps=fps=1 ${DEST_IMAGES}
```


# Reconstructing texture maps from photos
- http://math.stackexchange.com/q/681376/414308