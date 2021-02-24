#!/bin/bash

SW_LOC=../software/apps/alu_gpr

ALU_GPR_BIN=alu_gpr
ALU_GPR=$SW_LOC/$ALU_GPR_BIN

REMOTE_USER=root
REMOTE_PASSWD="111111"
REMOTE_IP=$1
REMOTE_HOME=/$REMOTE_USER
REMOTE_DIR=$REMOTE_HOME/alu_gpr_wp

SSH_TARGET=$REMOTE_USER@$REMOTE_IP
SSH_RUN="sshpass -p $REMOTE_PASSWD"
SSH_FLAG="-o StrictHostKeyChecking=no"

$SSH_RUN ssh $SSH_FLAG $SSH_TARGET "mkdir -p $REMOTE_DIR"
		
$SSH_RUN scp $SSH_FLAG $ALU_GPR $SSH_TARGET:$REMOTE_DIR
	
$SSH_RUN ssh $SSH_FLAG $SSH_TARGET "chmod 755 $REMOTE_DIR/$ALU_GPR_BIN"

echo "Please input command:"
read -e REMOTE_CMD

# Interactively launching ELF on remote FPGA board
while [ "$REMOTE_CMD" != "quit" ]
do
	if [[ "$REMOTE_CMD" = "reg_file_eval" ]] || [[ "$REMOTE_CMD" = "alu_eval" ]];
	then
		$SSH_RUN ssh $SSH_FLAG $SSH_TARGET "$REMOTE_DIR/$ALU_GPR_BIN $REMOTE_CMD"
	else
		echo "Usage:"
		echo "reg_file_eval	# Automatic evaluation of general purpose register file"
        echo "alu_eval	# Automatic evaluation of ALU"
        echo "quit			# quit program"
	fi
	echo "Please input command:"
	read -e REMOTE_CMD
done

# remove workspace on remote FPGA board after close GNOME terminal
$SSH_RUN ssh $SSH_FLAG $SSH_TARGET "rm -rf $REMOTE_DIR"

