
#!/bin/bash

function usage()
{
  cat <<-EOF
  usage: code_box.sh <-a ANDROID_PATH> <-s SDK_PATH> <-p PROFILE> <-m MANIFEST_NUM><-h>
  -a ANDROID_PATH  Where is the android code, please use the absolute path
  -s SDK_PATH      Where is the synaptics sdk path, please use the absolute path
  -t CODE_TYPE     O: AndroidO, P: AndroidP
  -m ISMANIFEST    copy the manifest 
  -p PROFLE        Profile name
  -h               Print the help info
  
  We currently support these profiles,please input correct profiles on option "-p"
  AndroidO:  oc_aosp_IP1400v2 oc_ginkgo oc_woofer2 oc_uplus_tvg2 oc_uplus_hg2 oc_uplus_hg2_iot 
  AndroidP:  sequoia_v4 sequoia_pl_v4 sequoia_google_v4 sequoia_google_ffv_v4 sequoia_google aosp_sequoia_noip_v4 aosp_sequoia_ab_v4

  Example: 
 ./code_box -a /home/sbt/O/android -s /home/sbt/O/sdk -p oc_gingko
EOF
  exit 0
}

function get_dirs()
{
  cmdstart=`dirname $0|cut -c 1`
  if  [ $cmdstart = '/' ]; then
    scripts_dir=`dirname $0`
  else
    scripts_dir="`pwd`/`dirname $0`"
  fi
  work_dir=`pwd`
  #echo $scripts_dir
}


# Check AndroidSDK codebase folder exist or not
function AndroidO_fetch_latest()
{
    Top=$1
    Android_Manifest_Branch=$2
    Android_Manifest=$3
    MANIFEST_ANDROID_URL=$4
    REPO=$5
    if [ ! -d $Top ]; then
      shellCheckCall echo "$Top folder doesn't exist, now create it!"
      shellCheckCall mkdir -p $Top
      shellCall cd $Top
      repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} ${Android_Manifest}
      shellCall echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      ret=$?
      if [ $ret -ne 0 ]; then
        cd $Top
        rm -rf *;
        repo sync -j24 --force-sync
        ret=$?
        if [ $ret -ne 0 ]; then
          rm -rf *;
          #rm -rf .repo
          shellCall repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} ${Android_Manifest}
          repo sync -j24 --force-sync
          ret=$?
          if [ $ret -ne 0 ]; then
            echo "Disable download scgerrit codebase from SHG mirror"
            cd $scripts_dir
            ./git-mirrors disable
            cd $Top
            exit $ret
          fi
        fi
      fi

    # Disable download scgerrit codebase from SHG mirror
      echo "Disable download scgerrit codebase from SHG mirror"
     shellCall cd $scripts_dir
     shellCall ./git-mirrors disable
     shellCall cd $Top
    else
      echo "$Top folder exist,repo clean and sync again"
      shellCall cd $Top
      shellCheckCall rm -rf *
      repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} ${Android_Manifest}
      shellCheckCall repo forall -c 'git clean -dxf; git reset --hard; rm -rf .git/rebase-*'
      shellCall echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      shellCall cd $scripts_dir
      echo "Disable download scgerrit codebase from SHG mirror"
      shellCheckCall ./git-mirrors disable
      shellCheckCall cd $Top
    fi
    echo "===================================================================================================================="
    echo "Android Code sync done on folder $Top "
    echo "===================================================================================================================="
}

function Android_fetch_manifest()
{
    Top=$1
    Android_Manifest_Branch=$2
    Android_Manifest=$3
    MANIFEST_ANDROID_URL=$4
    REPO=$5
    Build_Folder=$6
    Snapshot_Manifest=$7
    if [ ! -d $Top ]; then
      shellCheckCall echo "$Top folder doesn't exist, now create it!"
      shellCheckCall mkdir -p $Top
      shellCall cd $Top
      repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} ${Android_Manifest}
      shellCheckCall sshpass -p marvell88 scp sbt@10.70.24.51:$Build_Folder/$Snapshot_Manifest $Top/.repo/manifests 
      repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} $Snapshot_Manifest
      echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      ret=$?
      if [ $ret -ne 0 ]; then
        cd $Top
        rm -rf *;
        repo sync -j24 --force-sync
        ret=$?
        if [ $ret -ne 0 ]; then
          rm -rf *;
          #rm -rf .repo
          shellCall repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} ${Android_Manifest}
          repo sync -j24 --force-sync
          ret=$?
          if [ $ret -ne 0 ]; then
            echo "Disable download scgerrit codebase from SHG mirror"
            cd $scripts_dir
            ./git-mirrors disable
            cd $Top
            exit $ret
          fi
        fi
      fi
    # Disable download scgerrit codebase from SHG mirror
      echo "Disable download scgerrit codebase from SHG mirror"
      cd $scripts_dir
      ./git-mirrors disable
      cd $Top
    else
      echo "$Top folder exist,repo clean and sync again"
      shellCall cd $Top
      shellCheckCall rm -rf *
      repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} ${Android_Manifest}
      shellCheckCall sshpass -p marvell88 scp sbt@10.70.24.51:$Build_Folder/$Snapshot_Manifest $Top/.repo/manifests
      repo_init_cmd $MANIFEST_ANDROID_URL $REPO ${Android_Manifest_Branch} $Snapshot_Manifest
      shellCheckCall repo forall -c 'git clean -dxf; git reset --hard; rm -rf .git/rebase-*'
      shellCall echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      shellCall cd $scripts_dir
      echo "Disable download scgerrit codebase from SHG mirror"
      shellCheckCall ./git-mirrors disable
      shellCheckCall cd $Top
    fi
    echo "====================================================================================================================="
    echo "Android Code sync done on folder $Top "
    echo "====================================================================================================================="
}


function SDK_fetch_latest()
{
    Top=$1
    Sdk_Manifest_Branch=$2
    Sdk_Manifest=$3
    Manifest_Sdk_URL=$4
    REPO=$5
    if [ ! -d $Top ];then
      echo "$Top folder doesn't exist, now create it!"
      shellCheckCall mkdir -p $Top
      shellCall cd $Top
      repo_init_cmd $Manifest_Sdk_URL $REPO ${Sdk_Manifest_Branch} ${Sdk_Manifest}
      shellCheckCall repo forall -c 'git clean -dxf; git reset --hard; rm -rf .git/rebase-*'
      shellCall echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      echo "Disable download scgerrit codebase from SHG mirror"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors disable
      shellCall cd $Top
    else
      echo "$Top folder exist,repo clean and sync again"
      shellCall cd $Top
      shellCheckCall rm -rf *
      repo_init_cmd $Manifest_Sdk_URL $REPO ${Sdk_Manifest_Branch} ${Sdk_Manifest}
      shellCheckCall repo forall -c 'git clean -dxf; git reset --hard; rm -rf .git/rebase-*'
      shellCall echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      shellCall cd $scripts_dir
      echo "Disable download scgerrit codebase from SHG mirror"
      shellCall ./git-mirrors disable
      shellCall  cd $Top
    fi
    echo "================================================================================================================="
    echo "SDK Code sync done on folder $Top "
    echo "================================================================================================================="
}

function SDK_fetch_manifest()
{
    Top=$1
    Sdk_Manifest_Branch=$2
    Sdk_Manifest=$3
    Manifest_Sdk_URL=$4
    REPO=$5
    Build_Folder=$6
    Snapshot_Manifest=$7
    if [ ! -d $Top ];then
      echo "$Top folder doesn't exist, now create it!"
      shellCheckCall mkdir -p $Top
      shellCall cd $Top
      repo_init_cmd $Manifest_Sdk_URL $REPO ${Sdk_Manifest_Branch} ${Sdk_Manifest}
      shellCheckCall sshpass -p marvell88 scp sbt@10.70.24.51:$Build_Folder/$Snapshot_Manifest $Top/.repo/manifests
      repo_init_cmd $Manifest_Sdk_URL $REPO ${Sdk_Manifest_Branch} $Snapshot_Manifest
      shellCheckCall repo forall -c 'git clean -dxf; git reset --hard; rm -rf .git/rebase-*'
      shellCall echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      echo "Disable download scgerrit codebase from SHG mirror"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors disable
      shellCall cd $Top
    else
      echo "$Top folder exist,repo clean and sync again"
      shellCall cd $Top
      shellCheckCall rm -rf *
      repo_init_cmd $Manifest_Sdk_URL $REPO ${Sdk_Manifest_Branch} ${Sdk_Manifest}
      shellCheckCall sshpass -p marvell88 scp sbt@10.70.24.51:$Build_Folder/$Snapshot_Manifest $Top/.repo/manifests
      repo_init_cmd $Manifest_Sdk_URL $REPO ${Sdk_Manifest_Branch} $Snapshot_Manifest
      shellCheckCall repo forall -c 'git clean -dxf; git reset --hard; rm -rf .git/rebase-*'
      shellCall echo "Enable download scgerrit codebase from SHG mirror for the first download"
      shellCall cd $scripts_dir
      shellCall ./git-mirrors enable
      shellCall cd $Top
      shellCheckCall repo sync -j24 --force-sync
      shellCall cd $scripts_dir
      echo "Disable download scgerrit codebase from SHG mirror"
      shellCall ./git-mirrors disable
      shellCall  cd $Top
    fi
    echo "====================================================================================================================================="
    echo "SDK Code sync done on folder $Top "
    echo "====================================================================================================================================="
}


main()
{
  get_dirs
  . $scripts_dir/modules

  Manifest_Android_URL="ssh://sc-debu-git.synaptics.com:29420/by-projects/android/manifests"
  Manifest_Sdk_URL="ssh://sc-debu-git.synaptics.com:29420/debu/manifest"
  Repo="ssh://sc-debu-git.synaptics.com:29420/common/git-repo"
  Android_product='oc_aosp_IP1400v2 oc_ginkgo oc_woofer2 oc_uplus_tvg2 oc_uplus_hg2 oc_uplus_hg2_iot sequoia_v4 sequoia_pl_v4 sequoia_google_v4 sequoia_google_ffv_v4 sequoia_google aosp_sequoia_noip_v4 aosp_sequoia_ab_v4'
  
  Android_Path=""
  Sdk_Path=""
  Profile=""
  Is_manifest=""
  while getopts a:s:t:m:p:h arg
    do case $arg in
      a) Android_Path=$OPTARG;;
      s) Sdk_Path=$OPTARG;;
      t) Code_Type=$OPTARG;;
      m) Is_manifest=$OPTARG;;
      p) Profile=$OPTARG;;
      h) usage
         exit 0;;
      *) usage
         exit 1;;
    esac
  done


  if [ "$Android_Path" == "$Sdk_Path" ];then
    echo "Please input correct SDK folder !!!"
    usage
    exit 1
  fi

  if [ "$Sdk_Path" == "$Android_Path" ];then
    echo "Please input correct Android folder !!!"
    usage
    exit 1
  fi

  gre=`echo "$Android_product"|grep "$Profile"`
  echo "Profiles: $gre"

  if [ "is$Profile" == "is" ]; then
    echo "Please input correct profile !!!"
    usage
    exit 1
  elif [ "$gre" ];then
    echo "**************************************************************************************"
    echo "Prepared to sync the code for profile $Profile.."
    echo "**************************************************************************************"
  else
    echo "Please input correct profile !!!"
    exit 1
  fi

 # Caculate the line
  i=1
  SUM=`sed -n '$=' $scripts_dir/config`
  #echo "$SUM"
  while read line
  do
      arr[$i]="$line"
      i=`expr $i + 1`
  done < $scripts_dir/config

   #echo "$i"
   i=1
   for i in `seq $SUM` ;do
       #echo "${arr[$i]}"
       filter=`echo "${arr[$i]}"|grep "$Profile"`
       #echo $filter
       if [ "$filter" ];then
         Product=`echo ${arr[$i]}|awk -F ' ' '{print $1}'`
         Android_Branch=`echo ${arr[$i]}|awk -F ' ' '{print $2}'`
         Android_manifest=`echo ${arr[$i]}|awk -F ' ' '{print $3}'`
         Sdk_manifest=`echo ${arr[$i]}|awk -F ' ' '{print $4}'`
         Sdk_Branch=`echo ${arr[$i]}|awk -F ' ' '{print $5}'`
         Manifest_folder=`echo ${arr[$i]}|awk -F ' ' '{print $6}'`
       else
         continue
       fi
   done

  # create log folder and clean it.
  log_base_dir="$scripts_dir/out/$Profile/log"
  mkdir -p $log_base_dir
  rm -rf $log_base_dir/*
  ErrorLogFile=$log_base_dir/build.log

  # Show the detail parameters
  echo "*************************************************************"
  echo "Android_folder=$Android_Path"
  echo "SDK_fodler=$Sdk_Path"
  echo "Android_Branch=$Android_Branch"
  echo "Sdk_Branch=$Sdk_Branch"
  echo "Proile=$Product"
  echo "Android_manifest=$Android_manifest"
  echo "Sdk_manifest=$Sdk_manifest"
  echo "Manifest_folder"=$Manifest_folder
  echo "*************************************************************"
 
  # Specify the manfest related parameter according to the -m option
  if [ "is$Is_manifest" == "is" ];then

    #fetch the Android code
    AndroidO_fetch_latest $Android_Path $Android_Branch $Android_manifest $Manifest_Android_URL $Repo

    #fetch the SDK code
    SDK_fetch_latest $Sdk_Path $Sdk_Branch $Sdk_manifest $Manifest_Sdk_URL $Repo
  else
    expr $Is_manifest "+" 10 &> /dev/null
    if [ $? -eq 0 ];then
      if [ `echo $Is_manifest|awk '{print length($0)}'` -eq 12 ];then
        Build_Version=$Is_manifest
        Build_Date=${Is_manifest:0:6}
        Build_Day=${Is_manifest:0:8}
        if [ "$Product" == "oc_woofer2" ];then
          Build_folder=$Manifest_folder/$Build_Day/$Build_Version
        else
          Build_folder=$Manifest_folder/$Build_Date/$Build_Day/$Build_Version
        fi
        Android_snapshot_manifest=snapshot_${Android_manifest%.*}_$Build_Version.xml
        Sdk_snapshot_manifest=`echo snapshot_${Sdk_manifest%.*}_$Build_Version.xml |sed 's/\//\_/g'`
        Android_fetch_manifest $Android_Path $Android_Branch $Android_manifest $Manifest_Android_URL $Repo $Build_folder $Android_snapshot_manifest
        SDK_fetch_manifest $Sdk_Path $Sdk_Branch $Sdk_manifest $Manifest_Sdk_URL $Repo $Build_folder $Sdk_snapshot_manifest
      else  
        echo "Please input 12 numbers,for example: 201810101010"
        exit 1
      fi
    else
      echo "Please input numbers,for example: 201810101010"
      exit 1
    fi
  fi
  
}

main "$@"

