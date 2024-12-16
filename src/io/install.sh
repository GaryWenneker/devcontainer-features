#!/bin/sh
set -e

echo "Activating feature 'iO'"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final 
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

cat > /usr/local/bin/ssh-setup \
<< EOF
#!/bin/bash

COL='\033[1;33m'
WHITE='\033[1;37m'


eval "$(ssh-agent -s)"

clear

echo -e "${COL}
                 %%%%%                        %%%%%                        
                 %%%%%%%%               %%%%%%%%%%%%%%%%                   
                 %%%%%%%%%%          %%%%%%%%%%%%%%%%%%%%%%                
                 %%%%%%%%%         %%%%%%%%%%%%%%%%%%%%%%%%%%              
                  %%%%%%%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%             
                   %%%%%%        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
                    %%%%        %%%%%%%%%%%          %%%%%%%%%%%           
                      %%%       %%%%%%%%%%             %%%%%%%%%%          
                     %%%%%%    %%%%%%%%%%              %%%%%%%%%%          
                    %%%%%%%%   %%%%%%%%%                %%%%%%%%%          
                   %%%%%%%%%%  %%%%%%%%%                %%%%%%%%%          
                  %%%%%%%%%%%   %%%%%%%%%              %%%%%%%%%%          
                  %%%%%%%%%%%   %%%%%%%%%%            %%%%%%%%%%           
                 %%%%%%%%%%%     %%%%%%%%%%%%%    %%%%%%%%%%%%%%           
                %%%%%%%%%%%%      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
               %%%%%%%%%%%%        %%%%%%%%%%%%%%%%%%%%%%%%%%              
               %%%%%%%%%%%          %%%%%%%%%%%%%%%%%%%%%%%%               
                 %%%%%%%%             %%%%%%%%%%%%%%%%%%%%                 
                      %%                  %%%%%%%%%%%%                     
${WHITE}"
echo -n "Please enter key name: "
read key
printf "Please enter your email-adress:"
read email


ssh-keygen -t rsa -b 8192 -C "$email" -f ~/.ssh/$key

clear

FILE=~/.ssh/config
if [ -f "$FILE" ]; then
	# add line to the config file
	echo "Host *
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/$key" >> ~/.ssh/config
else 
	printf "$FILE created and $key added to ssh store for persistency"
	echo "Host *
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/$key" > ~/.ssh/config
fi

printf "$key Key added to $FILE for persistency.\n\n"

printf "Please add this public key to your git account or in bridge:\n\n"
echo "-----BEGIN SSH2 PUBLIC KEY-----"
cat ~/.ssh/$key.pub
echo "-----END SSH2 PUBLIC KEY-----"
printf "\n\n"


ssh-add ~/.ssh/$key

EOF

chmod +x /usr/local/bin/ssh-setup