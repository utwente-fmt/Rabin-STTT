#!/bin/bash

# ALG
#RABIN_ALG="ltl3dra"

# binaries
DVE_LTSMIN="dve2lts-mc"
LTSMIN=${DVE_LTSMIN}

# file extension
DVE_EXTENSION="dve"
EXTENSION=$DVE_EXTENSION
HOA_EXT="ltl3tela.hoa"

# variables
TIMEOUT_TIME="600s" # 15 minutes timeout for program (10 minute timeout is provided in compilation)
MAX_TRIES="3" # number of retries after known failures

# misc fields
BENCHDIR=`pwd`
ALL_OUTPUT="${BENCHDIR}/all_output.out"
TMPFILE="${BENCHDIR}/test.out" # Create a temporary file to store the output
FAILFOLDER="${BENCHDIR}/failures"

# input graphs folders
TACAS_FOLDER="${BENCHDIR}/tacas14"
LTL_FOLDER=${TACAS_FOLDER}

# results
TACAS_RESULTS="${BENCHDIR}/results.csv"
RESULTS=$TACAS_RESULTS

trap "exit" INT #ensures that we can exit this bash program

# create new output file, or append to the exisiting one
create_results() {
    output_file=${1}
    if [ ! -e ${output_file} ]
    then
        touch ${output_file}
        # Add column info to output CSV
        echo "model,alg,rabinpairorder,workers,buchi,ltl,errmsg,time,date,sccs,ustates,utrans,tstates,ttrans,selfloop,claimdead,claimfound,claimsuccess,cumstack,autsize,rabinpairs,ftrans,formula,hoa" > ${output_file}
    fi
}

# create necessary folders and files
init() {
    if [ ! -d "${FAILFOLDER}" ]; then
      mkdir "${FAILFOLDER}"
    fi
    if [ ! -d "${BENCHDIR}/results" ]; then
      mkdir "${BENCHDIR}/results"
    fi
    touch ${ALL_OUTPUT}
    touch ${TMPFILE}
    create_results ${TACAS_RESULTS}
}


# test_ltsmin BASE INPUT ALG WORKERS
# e.g. test_ltsmin exit.3 exit.3_T_002.ltl 1 ndfs ba
test_ltsmin() {
    if [ ! $# = 4 ]; then
        echo "Error: invalid number of arguments"
        echo "USAGE:"
        echo "     test_ltsmin  BASE  INPUT  WORKERS  ALG"
        echo "e.g. test_ltsmin  exit.3  exit.3_T_002  1  ndfs"
        exit
    fi

	base=${1%/}
	input=${2%_$HOA_EXT}
	hoaworkers=${3}
	alg=${4}
	#buchi=${5} # ignored

    model="${LTL_FOLDER}/${base}/${base}.${EXTENSION}"
    hoafile="${LTL_FOLDER}/${base}/${input}_$HOA_EXT"

	if [ ! -f $hoafile ]; then
		echo "File does not exist: $hoafile"
		return
	fi

    try_again=0
    retry=1

    while [  $retry -eq 1 ]; do
        let retry=0
		echo "Running ${alg} on $2 with ${workers} worker(s)"
		
        ERR_MSG="OK"
        # run the algorithm
        timeout ${TIMEOUT_TIME} time ${LTSMIN} --state=table -s28 --strategy=${alg} --threads=${workers} \
 --ltl-semantics=spin --hoa=${hoafile} ${model} --rabin-order=seq -v --when  &> ${TMPFILE}

        if [ "$?" = "124" ]; then
            echo "- Timeout!"
            ERR_MSG="TLE"
        fi

	if grep -q "ERROR: Timeout" ${TMPFILE}
	then
	    echo "- Timeout"
	    ERR_MSG="TLE"
	fi

        ## Store output
        cat ${TMPFILE} >> ${ALL_OUTPUT}

        ## check for errors
        if grep -q "slab->cur_len != SIZE_MAX\
\|isba_size_int(balloc) == index + 1\
\|There is no group that can produce edge\
\|strcomp(pval(str), name, slab) == 0\
\|segmentation fault" "${TMPFILE}"
        then
            let try_again=$try_again+1
            if [ "$try_again" -lt "$MAX_TRIES" ]
            then 
                echo "- Found known failure, trying again ($try_again)"
                let retry=1
            else
                echo "- Found known failure, already tried $try_again times, reporting error and continuing.."
                ERR_MSG="FAIL"
            fi
        fi
        if grep -q "hash table full! Change\
\|out of memory on allocating\
\|mmap failed for" "${TMPFILE}"
        then
            echo "- Out of memory!"
            ERR_MSG="MEM"
        fi
    done

    # analyze the results
    python parse-output.py "${input}" "${alg}" "${workers}" "${HOA_EXT%.hoa}" "${FAILFOLDER}" "${TMPFILE}" "${ERR_MSG}" "${RESULTS}"
}

#time test_all_tacas14_ltsmin 1
test_all_tacas14_ltsmin() {
	if [ ! $# = 1 ]; then
		echo "Error: invalid number of arguments"
		echo "USAGE:"
		echo "     test_all_tacas14_ltsmin  WORKERS"
		echo "e.g. test_all_tacas14_ltsmin  1"
		exit
	fi
	workers=${1}

	RESULTS=$TACAS_RESULTS
	LTL_FOLDER=$TACAS_FOLDER
	LTSMIN=$DVE_LTSMIN
	EXTENSION=$DVE_EXTENSION

	for folder in `(cd ${LTL_FOLDER}; ls -d */)`
	do
		for ltl in `ls ${LTL_FOLDER}/${folder} | grep -e "\.ltl"`
		do
			echo ""
			echo "${ltl%.ltl}"
			echo ""
			for count in `seq 1`
			do
				HOA_EXT="ltl3tela.hoa"
				echo ${folder} "${ltl%.ltl}_$HOA_EXT" ${workers} favoid
				#HOA_EXT="finless.hoa"
				#test_ltsmin ${folder} "${ltl%.ltl}_$HOA_EXT" ${workers} ufscc
				#test_ltsmin ${folder} "${ltl%.ltl}_$HOA_EXT" ${workers} favoid
				#HOA_EXT="tgba.hoa"
				#test_ltsmin ${folder} "${ltl%.ltl}_$HOA_EXT" ${workers} ufscc
				#HOA_EXT="ltl3dra.hoa"
				#test_ltsmin ${folder} "${ltl%.ltl}_$HOA_EXT" ${workers} favoid
				#HOA_EXT="rabinizer3.hoa"
				#test_ltsmin ${folder} "${ltl%.ltl}_$HOA_EXT" ${workers} favoid
				#RABIN_ALG="ltl3hoa"
				#test_ltsmin ${folder} ${ltl} ${workers} favoid gra
				#RABIN_ALG="ltl3dra"
				#test_ltsmin ${folder} ${ltl} ${workers} favoid readrabin
				#RABIN_ALG="rabinizer3"
				#test_ltsmin ${folder} ${ltl} ${workers} favoid readrabin
				#RABIN_ALG="tgbarabin"
				#test_ltsmin ${folder} ${ltl} ${workers} favoid readrabin
			done
		done
	done
}


# initialize
init


############################################################

test_all_tacas14_ltsmin 16

############################################################


# cleanup
rm ${TMPFILE}



