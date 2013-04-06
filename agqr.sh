if [ $# -eq 2 ]; then
    RECTIMEMIN=$1
    TITLE=$2
else
    echo "usage : $0 station RECTIMEMIN title"
    exit 1
fi

OUTFILEBASEPATH="."
SUFFIX=".flv"
OUTFILENAME=${OUTFILEBASEPATH}/${TITLE}_`date +%Y-%m-%d_%H%M`${SUFFIX}
RECTIME=`expr ${RECTIMEMIN} \* 60`

rtmpdump --rtmp "rtmpe://fms2.uniqueradio.jp/" --playpath "aandg5" --app "?rtmp://fms-base1.mitene.ad.jp/agqr/" --stop $RECTIME --live -o $OUTFILENAME
