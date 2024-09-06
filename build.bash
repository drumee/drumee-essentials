#!/bin/bash

set -e
if [ "$UID" == "0" ]; then
  echo "You should not run this builder with root privilege"
  exit 1
fi

base="$(dirname "$(readlink -f "$0")")"
source ${base}/utils/env.sh
source ${base}/utils/functions.sh

version=$(get_version $base)
email=$(get_email $base)
build_dir=$(get_build_dir ${base}/build/$version)

rm -rf $build_dir
mkdir -p $build_dir/files/var

rsync -ar --exclude-from="nosync" ${base}/var/lib $build_dir/files/var/
rsync -ar --exclude-from="nosync" ${base}/usr $build_dir/files/
rsync -ar --exclude-from="nosync" ${base}/etc $build_dir/files/


cd $build_dir
packagename=drumee-infra
package=${packagename}_${version}
echo "BUILDING PACKAGE $package IN $build_dir"

dh_make --native --yes --indep --packagename $package --email $email
rsync -rav --delete ${base}/debian/ $build_dir/debian/
dpkg-buildpackage -us -uc -k$email

#copyToTarget $base/build/${package}

