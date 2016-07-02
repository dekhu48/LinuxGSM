#!/bin/bash
# LGSM command_update_functions.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
lgsm_version="210516"

# Description: Deletes the functions dir to allow re-downloading of functions from GitHub.

function_selfname="$(basename $(readlink -f "${BASH_SOURCE[0]}"))"
check.sh
fn_print_dots "Updating functions"
fn_script_log_info "Updating functions"
sleep 1
echo -ne "\n"

# Removed legecy functions dir
if [ -n "${rootdir}" ]; then
	if [ -d "${rootdir}/functions/" ]; then
		rm -rfv "${rootdir}/functions/"
		exitcode=$?
	fi
fi

if [ -n "${functionsdir}" ]; then
	if [ -d "${functionsdir}" ]; then

		cd "${functionsdir}"
		for functionfile in *
		do
			echo -ne "   checking ${functionfile}...\c"
			function_file_diff=$(diff "${functionsdir}/${functionfile}" <(${curlcmd} -s "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"))
			if [ "${function_file_diff}" != "" ]; then
				${curlcmd} -s --fail "https://raw.githubusercontent.com/${githubuser}/${githubrepo}/${githubbranch}/${github_file_url_dir}/${functionfile}"
				local exitcode=$?
				if [ "${exitcode}" != "0" ]; then
					echo -ne "   checking ${functionfile}...FAIL"
					rm -rfv "${functionsdir}/${functionfile}"
				else
					echo -ne "   checking ${functionfile}...UPDATE"
					rm -rfv "${functionsdir}/${functionfile}"
					fn_update_function
				fi
			else
				echo -ne "   checking ${functionfile}...OK"
			fi
		done
	fi
fi

if [ "${exitcode}" == "0" ]; then
	fn_print_ok "Updating functions"
	fn_script_log_pass "Success! Updating functions"
	exitcode=0
else
	fn_print_fail "Updating functions"
	fn_script_log_fatal "Failure! Updating functions"
	exitcode=1
fi
echo -ne "\n"
core_exit.sh