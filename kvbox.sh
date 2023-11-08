#!/bin/bash

# Function to check env files
check_env(){   
    if [ -f .env ]; then
        echo "Checking environment variables from .env file."
    else
        echo ".env file not found. Make sure it exists in the same directory as this script."
        exit 1  # Exit the script with an error code (1)
    fi
}

# Function to display usage instructions
usage() {
  echo "Usage: $0 <lab_name> or remove"
  echo "Available labs: lab1, lab2"
  exit 1
}

# Function to remove a lab
remove_lab() {
    lab_selected=$(<lab.txt)
    echo "Removing $lab_selected"
    if [ -d "labs/$lab_selected" ]; then
        cd "labs/$lab_selected"
        files=("add_ssh_fingerprints.sh" ".env")
        for file in "${files[@]}"; do
            if [ -e "$file" ]; then
                echo "Removing $file"
                rm "$file"
            fi
        done
        rm -Rf ./ansible ./yaml ./mkdocs
        vagrant destroy -f
        cd .. 
        cd ..        
        rm lab.txt
        labe_selected=""
        echo "Lab $lab_selected removed."
    else
        echo "Lab $lab_selected does not exist."
    fi    
}

main(){

    # Check for the correct environment variables
    check_env

     # Check for the correct number of arguments
    if [ $# -ne 1 ]; then
    usage
    fi

    lab_name="$1"

    case "$lab_name" in
    lab1)
        vagrant_file="labs/lab1/Vagrantfile"
        ;;
    lab2)
        vagrant_file="labs/lab2/Vagrantfile"
        ;;      
    remove)
        remove_lab
        ;;
    *)
        echo "Invalid lab name: $lab_name"
        usage
        ;;
    esac
    
    # Check if the Vagrantfile exists
    if [ -f "$vagrant_file" ]; then
        echo "Using Vagrantfile: $vagrant_file"    
        cp scripts/add_ssh_fingerprints.sh "labs/$lab_name/"
        cp ".env" "labs/$lab_name/"
        cp -r "ansible" "labs/$lab_name/"
        cp -r "yaml" "labs/$lab_name/"
        cp -r "mkdocs" "labs/$lab_name/"
        echo "$lab_name" > lab.txt
        cd "labs/$lab_name"   
        echo "Running $vagrant_file"
        vagrant up    
    fi    
}

main "$@"