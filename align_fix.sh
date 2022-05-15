#!/bin/bash

echo "run struct fields alignment fix"

# putting linter's output to a json file
golangci-lint run -c ../.golangci.yml --out-format json --modules-download-mode=vendor > linter_out.json

# creating packages map for sanitizing
declare -A packages
i=0
while [ $i -gt -1 ]; do
     issue=$(jq -c -r ".Issues["$i"]" linter_out.json)
     if [[ "$issue" = "null" ]]; then
         i=-1
         break
     fi
     if [[ $(echo "$issue" | jq -c -r .FromLinter) = "govet" ]]; then
         filepath=$(echo "$issue" | jq -c -r .Pos.Filename)

         # skipping test files
         if [[ "$filepath" =~ .*"_test.go".* ]]; then
           i=$((i+1))
           continue
         fi

         # splitting file path to an array
         filePathArr=(${filepath//"/"/ })

         # removing file name from an array
         len="${#filePathArr[@]}"
         cleanedFilePathArr=(${filePathArr[@]:0:$((len-1))})

         # here is the package name that is need to be fixed
         package=$(printf "/%s" "${cleanedFilePathArr[@]}")
         packages[$package]="$package"
     fi

     i=$((i+1))
done

# fixing each package via fieldalignment tool
for package in "${packages[@]}" ; do
    fieldalignment -c 0 -fix ./"$package"
done

# deleting a file with a linter's output
rm -Rf linter_out.json

echo "done"
