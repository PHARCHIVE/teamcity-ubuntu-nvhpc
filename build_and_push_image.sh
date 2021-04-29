BASEDIR=$(dirname "$0")
RELEASE=${1:-20.04}
REGISTRY=${2:-"129.104.6.165:32219"}
IMAGE="phare/teamcity-ubuntu-nvhpc"
FULL_NAME="${REGISTRY}/${IMAGE}:${RELEASE}"
$BASEDIR/build_image.sh $RELEASE $REGISTRY
docker push $FULL_NAME
