#!/bin/sh
#
# Instructions:
# Make sure you run this script as the user to be considered as admin, this setups up UID permissions so that
# the ruby-proctor app ONLY can access the questions with elevated permissions. 
# First Argument is path of where you want to store your quizlog file
# Second Argument is path for quiz application (Which will be chowned to you, with the suid flag set for applications with executable rights for everyone

echo "Welcome to Ruby Proctor Linux Setup!"
read -p "Enter Quizlog Storage Path for admin user (Make sure you have access!) [~/.ruby-proctor/.quizlog]: " quizlog_path
quizlog_path=${quizlog_path:-'~/.ruby_proctor/.quizlog'}

read -p "Enter Application Path (Where to Copy and Make Executable for Users with SUID Enabled) [/bin/ruby-proctor]: " quizlog_path
app_path=${quizlog_path:-Richard}
echo $app_path

echo -n "Making Empty Quizlog file..."
mkdir -p "${quizlog_path%/*}" && touch "$quizlog_path"
echo "Done!"

echo -n "Copying Ruby Proctor & Creating Quizlog Symlink..."
mkdir -p "${app_path%/*}"
cp ruby-proctor "$app_path"
ln -s $quizlog_path .quizlog
echo "Done!"

echo -n "Setting owner & group to ${USER:=$(/usr/bin/id -run)}..."
chown ${USER:=$(/usr/bin/id -run)}:$USER "$app_path"
echo "Done!"

echo -n "Setting Permissions..."
chmod 771 "$app_path"
chmod u+s "$app_path"
echo "Done! Ruby Proctor is ready to use! Run the command via "$app_path -h" to see possible parameters"