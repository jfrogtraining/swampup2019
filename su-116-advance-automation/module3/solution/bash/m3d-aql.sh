# Exercise 3d-a - Find your uploaded files to tomcat with properties submitter=your name
# Use generalAQLSearch in your main script to call the function generalAQLSearch ()

# Exercise 3d-b - AQL find all jars with impl.class
# You have just been informed that “junit-4.11.jar” class library has a serious null pointer exception 
# issue. You must immediately find all products that have this issue and have development build with 
# latest remediation. 
aqlsearch () {
  echo "Listing all jars with junit-4.11.jar; AQL file: $1"
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST  "${ART_URL}"/api/search/aql -T $1))
  local jarList=$(echo ${response[@]} | jq '.results[].archives[].items[] | .repo + "/" + .path + "/" + .name ')
  for jar in "${jarList[@]}"
  do
     printf "${jar} \n"
  done
}

# Exercise 3d-d - Clean Up Example
# List all files that meet the following criteria:
# - They are the largest 100 files which were created by the “jenkins” user.
# - Their extension is either tar or zip.
# - They downloaded less than 1.
# - Their size is greater than 100Mb
# - List the build that produces them. 
generalAQLSearch () {
  echo "Listing all docker images greater than 100Mb, and downloaded less than 1"
  local response=($(curl -s -u"${USER}":"${ART_PASSWORD}" -X POST  "${ART_URL}"/api/search/aql -T $1))
  local jarList=$(echo ${response[@]} | jq '.results[]')
  for jar in "${jarList[@]}"
  do
     printf "${jar} \n"
  done
}
