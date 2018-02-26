#!/bin/bash -xe

test ! -f $SOURCE_FILE && \
    echo "Your keystonerc file should be mounted to $SOURCE_FILE" && \
    exit 1

source $SOURCE_FILE

if [ ! -d $LOG_DIR ]
then
    echo "------------WARNING------------"
    echo "-----Your log_dir is not mounted to $LOG_DIR-----"
    echo "-----$LOG_DIR will be created-----"
    echo "-----Be attention: if you've run the container with '--rm' key-----"
    echo "-----All reports will be erased-----"
    echo "-------------------------------"
    mkdir -p $LOG_DIR
fi

CONF_FILE_PATH="${LOG_DIR}/${TEMPEST_CONF}"
if [[ "${TEMPEST_CONF:0:1}" = '/' ]]; then
    CONF_FILE_PATH="${TEMPEST_CONF}"
fi

if [ ! -f $CONF_FILE_PATH ]
then
    if [ -f /var/lib/$TEMPEST_CONF ]
    then
        cp /var/lib/$TEMPEST_CONF $CONF_FILE_PATH
    else
        echo "Please put your tempest.conf file to log_dir"
        exit 1
    fi
fi
export TEMPEST_CONF=$CONF_FILE_PATH

if [ ! -f $LOG_DIR$SKIP_LIST ]
then
    if [ -f /var/lib/$SKIP_LIST ]
    then
        cp /var/lib/$SKIP_LIST $LOG_DIR$SKIP_LIST
    else
        echo "Please put your skip.list file to log_dir"
        exit 1
    fi
fi
export SKIP_LIST=$LOG_DIR$SKIP_LIST

if [ -n "${REPORT_SUFFIX}" ]
then
    report="report_${REPORT_SUFFIX}"
else
    report='report_'$SET'_'`date +%F_%H-%M`
fi
log=$LOG_DIR/$report.log
rally-manage db recreate
rally deployment create --fromenv --name=tempest
rally verify create-verifier --type tempest \
    --name tempest-verifier \
    --source /var/lib/tempest \
    --version $TEMPEST_TAG \
    --system-wide
rally verify add-verifier-ext --source /var/lib/heat-tempest-plugin \
    --version $HEAT_TAG

bash /var/lib/generate_resources.sh    
bash /var/lib/prepare_env.sh

rally verify configure-verifier --extend $TEMPEST_CONF --reconfigure
rally verify configure-verifier --show | tee -a $log

if [ -n "$CUSTOM" ]
then
    rally verify start \
        --skip-list $SKIP_LIST \
        $CUSTOM  | tee -a  $log
else
    rally verify start \
        --skip-list $SKIP_LIST \
        --concurrency $CONCURRENCY \
        --pattern set=$SET | tee -a $log
fi
rally verify report --type junit-xml --to $LOG_DIR/$report.xml
rally verify report --type html --to $LOG_DIR/$report.html
