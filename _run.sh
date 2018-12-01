export PROJECT=$1

if [[ $# -eq 0 ]] ; then
    echo 'Usage: ./_run.sh project_name'
    exit 0
fi

mkdir -p projects/${PROJECT}/out/openMVS

alias dmvg="docker run --rm -it -v ${PWD}:/work spikeheap/openmvg"
alias dmvs="docker run --rm -it -v ${PWD}:/work spikeheap/openmvs"

dmvg openMVG_main_SfMInit_ImageListing  -i /work/projects/${PROJECT}/images -o /work/projects/${PROJECT}/out/matches -d /openMVG/src/openMVG/exif/sensor_width_database/sensor_width_camera_database.txt

dmvg openMVG_main_ComputeFeatures  -i /work/projects/${PROJECT}/out/matches/sfm_data.json -o /work/projects/${PROJECT}/out/matches

dmvg openMVG_main_ComputeMatches  -i /work/projects/${PROJECT}/out/matches/sfm_data.json -o /work/projects/${PROJECT}/out/matches

dmvg openMVG_main_IncrementalSfM  -i /work/projects/${PROJECT}/out/matches/sfm_data.json -m /work/projects/${PROJECT}/out/matches -o  /work/projects/${PROJECT}/out/

dmvg openMVG_main_openMVG2openMVS -i /work/projects/${PROJECT}/out/sfm_data.bin -o /work/projects/${PROJECT}/out/openMVS/scene.mvs


# outputs scene_dense.mvs
#dmvs DensifyPointCloud /work/projects/${PROJECT}/out/openMVS/scene.mvs

# can be used on scene.mvs or scene_dense.mvs
# outputs ????
dmvs ReconstructMesh /work/projects/${PROJECT}/out/openMVS/scene.mvs

# can be used on scene.mvs or scene_dense.mvs
# outputs scene_mesh_refine.mvs
dmvs RefineMesh /work/projects/${PROJECT}/out/openMVS/scene_mesh.mvs

# can be used on scene.mvs, scene_dense.mvs, scene_mesh_refine.mvs, or scene_dense_mesh_refine.mvs
# outputs scene_mesh_refine.mvs
dmvs TextureMesh /work/projects/${PROJECT}/out/openMVS/scene_mesh_refine.mvs
