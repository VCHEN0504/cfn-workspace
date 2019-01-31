# Linux Workstation

This project is to provide an automated mechanism for provisioning a Linux workstation that hosts on AWS and runs various development software. 

The initial requirement was to utilize AWS Workspaces that provides similar capability as the legacy workstation.  However, due to the following challenges, AWS Workspaces is not a feasible approach for Linux workstation.  Instead, we will host the worksation on an EC2 instance instead.

* Linux Workspaces service only allows the use of custom images created from a **AWS standard workspaces** image. We have to go through the steps of launching a standard Workspace, customizing/harden it and creating a bundle out of that workspace.
* Amazon does not support web access for Linux Workspaces currently. Requiring a [Workspace Client](https://clients.amazonworkspaces.com) installation in order to access a Linux Workspace is not possible on high side environment.

At the time of this writing, a prototype of Linux Workstation has been created using the following resources.   The remaining of this document will cover the details and instructions of this prototype.

* EC2 AMI: spel-minimal-centos-7-hvm-2018.12.1.x86_64-gp2
* CloudFormation template: Templates/make_workspace_linux_EC2.tmplt.json
* Cloud-Init script:  SupportFiles/ws-tools.sh
* Jenkins pipeline job with Deployment/EC2-Instance.groovy script
* Tools bundle

## EC2 AMI

The spel-minimal-centos-7-hvm-2018.12.1.x86_64-gp2 is the hardened AWS AMI image that our customer approves.

## CloudFormation

The Templates/make_workspace_linux_EC2.tmplt.json creates an EC2 instance, downloads scripts and tools bundle from S3, and executes the script to install all of the software listed below.

## Cloud-Init script

The SupportFiles/ws-tools.sh installs the following applications/tools.  It references the latest versions of software as the time of this writing.  

* Watchmaker
* GNOME
* VNC Server
* Firefox - Default GNOME installation includes Firefox
* Anaconda
* ATOM
* Eclipse
* IntelliJ
* Emacs
* Gradle
* Maven
* Git
* Ruby
* Node.JS
* Pycharm
* Asciidoctor tool chains 
* Visual Studio Code
* Mongo db Client – Mongo Shell 
* MySQL and MySQL Workbench
* Joomla
* Qt Assistant and creator 

## Tools Bundle

The tools.tar.gz contains the following folders.  Inside each folder, it has tool binary file, shell script, and/or config file. It needs to be uploaded to S3.

* anaconda: anaconda.desktop, anaconda.sh
* asciidoctor: demo.adoc, readme, rubygem-asciidoctor-1.5.6.1-1.el7.noarch.rpm 
* atom: atom.x86_64.rpm
* git: endpoint-repo-1.7-1.x86_64.rpm
* gradle: gradle-5.1.1-bin.zip, gradle.sh
* intellij: ideaIC-2018.3.3.tar.gz, jetbrains-idea-ce.desktop
* Joomla: Joomla_3.9.2-Stable-Full_Package.tar.gz
* mongo: mongodb-org-shell-4.0.5-1.el7.x86_64.rpm
* mysql: epel-release-6-8.noarch.rpm, epel-release-7-11.noarch.rpm, mysql80-community-release-el7-1.noarch.rpm, mysql-workbench-community-8.0.13-1.el7.x86_64.rpm
* nodejs: node-v11.6.0-linux-x64.tar.xz
* pycharm: pycharm-community-2018.3.3.tar.gz, pycharm.desktop
* qt: qt-assistant-4.8.7-2.el7.x86_64.rpm
* vscode: code-1.30.2-1546901769.el7.x86_64.rpm

To build a tools.tar.gz:
```command line
	_cd <source home>_
	_tar -cvf tools.tar *_
	_gzip tools.tar_
	_aws s3 cp tools.tar.gz s3://<bucket and folder>/tools.tar.gz_
	_aws s3api put-object-acl --bucket <bucket name> --key <folder name>/tools.tar.gz --grant-read uri=http://acs.amazonaws.com/groups/global/AllUsers_
```

## Jenkins Job

An Jenkins pipeline job is created with the following parameters:

* AwsRegion:  Amazon region to deploy resources info
* AwsCred: Jenkins-stored AWS credential with which to execute cloud-layer commands
* GitCred: Jenkins-stored Git credential with which to execute Git commands
* GitProjUrl: SSH URL from which to download the Jenkins Git projet
* GitProjBranch: Project-branch to use from the Jenkins git project
* CfnStackRoot: Unique token to prepend to all stack-element names
* TemplateUrl: S3-hosted URL for the EC2 CloudFormation template file
* AdminPubkeyURL: S3-hosted URL for file containing admin-group SSH key-bundle
* AmiId:  ID of the AMI to launch
* CfnEndpointUrl: URL to the CloudFormation Endpoint. Default: https://cloudformation.us-east-1.amazonaws.com
* EpelRepo: Name of network-available EPEL repo.  Default: epel
* InstallToolScriptURL: S3-hosted URL for the scripts (e.g., ws-tools.sh) that executes commands to install various dev tools
* WorkstationUserName: User name of the workstation owner
* WorkstationUserPasswd: Default password of the workstation owner. 
* InstanceRole: IAM instance role to apply to the instance
* InstanceType: Amazon EC2 instance type
* KeyPairName: Public/private key pair used to allow an operator to securely connect to instance immediately after the instance-SSHD comes online
* NoPublicIp: Controls whether to assign the instance a public IP. Recommended to leave at 'true' _unless_ launching in a public subnet. Default: true
* NoReboot: Controls whether to reboot the instance as the last step of cfn-init execution. Default: false
* RipRpm: Name of preferred pip RPM. Default: python2-pip
* PrivateIp: (Optional) Set a static, primary private IP. Leave blank to auto-select a free IP
* ProvisionUserName: Name for remote-administration account
* PyStache: Name of preferred pystache RPM. Default: pystache
* RootVolumeSize: Size in GB of the EBS volume to create. If smaller than AMI default, create operation will fail; If larger, partition containing root * device-volumes will be upsized. Recommend: 50
* SecurityGroupIds: List of security groups to apply to the instance
* SubnetId: ID of the subnet to assign to the instance
* ToolsURL: S3-hosted URL for the gzip/tar file which contains all of the dev tools binaries
* VNCServerPasswd: Default VNC server password. (Specific to VNC's requirement) Password must contain at least one letter, at least one number, and be *longer than six characters.
* WatchmakerConfig: (Optional) Path to a Watchmaker config file.  The config file path can be a remote source (i.e. http[s]://, s3://) or local directory (i.e. file://)
* WatchmakerEnvironment: Environment in which the instance is being deployed. Default: dev
* SSHKey:  Provision User's SSH Key

Set Pipeline Definition: Fill in the following fields
* SCM: Git
* Repository URL  
* Credential 
	
Set Pipeline Script Path: Fill in "Deployment/EC2-Instance.groovy"
	
## Instruction on buidling and using the Linux workstation

Prerequisites:
1. Create the following three credentials in Jenkins:
	1. AwsCred: Jenkins-stored AWS credential with which to execute cloud-layer commands
	1. GitCred: Jenkins-stored Git credential (user name and password) with which to execute Git commands
	1. SSHKey:  SSH user name and private key	
1. The SSH public key is added to the file, specified in the AdminPubkeyURL parameter
1. An Jenkins job is created and pre-configured as per the instruction above.
1. The CloudFormation template, Cloud-init script, and tool bundles are uploaded to S3. The S3 URLS will be specified in the Jenkins TemplateUrl, InstallToolScriptURL, and ToolsURL parameters
1. An AWS EC2 instance profile/role with correct permissions have been creasted.  It will be used in the Jenkins InstanceRole parameter.
1. An AWS Security Group(s) have been created. It will be specified in the Jenkins SecurityGroupIds parameter

Steps:
1. Build the Jenkins job with parameters (see the list of parameters above). Based on the current CloudFormation template, it takes around 25 minutes to complete.  The template timeout is set to 45 minutes.
1. Once the EC2 is created successfully, connect to rdsh.dicelab.net. 
1. Start pageant, and add your SSH private key
1. Use putty or MobaXterm to connect to the EC2 using the account name, specified in the ProvisionUserName parameter

	* On MobaXTerm, create a SSH session:
		1. Click Session -> SSH -> Enter Remote Host with the EC2 private IP adress
		1. Click Advanced SSH settings, check the "Use private key" box and enter the location of the SSH private key
		
1. Set a default password for the workstation owner, specified in the WorkstationUserName parameter.  Note: the CloudFormation template can be enhanced to automate this step. 

1. On MobaXterm, crate a VNC session:
	* Click Session -> VNC -> Enter Remote Host with the EC2 private IP adress and change the port to 5901
		
1. Start VNC, and enter the password when prompted, the password is specified in the VNCServerPasswd parameter.
1. Verify the installation of the tools:

	* The following IDE apps can be accessed at the Application menu -> programming sub-menu
		* Anaconda
		* Atom
		* EclipseEmac
		* Git
		* Intellij IDEA
		* MySQL
		* PyCharm
		* Q4 Assistant
		* QT Creator
		* Virtual Studio Code
			
		
	* The following command line tools, type the following commands to verify: 
		* gradle -v
		* mvn -version
		* ruby -v
		* node -v
		* npm -v
		* mongo -version
		* asciidoc -v

## Future Enhancement

1. The ws-tools.sh only does default installation. Further configuratin for each tool may be required. 
1. Consideration for further automation using CloudFormation: 
	1. Create EC2 instance profile and instance role
	1. Create Security Group(s)
1. Add constraints to Jenkins WorkstationUserName, WorkstationUserPasswd, and ProvisionUser, the value must be complied with agency's security policy
1. The following code does not work in the UserData section of the CloudForamtion template, require further troubleshoot.  Workaround: manually set a default password for the workstation owner.
	
	```cloud-config
   	"chpasswd:\n",
	"  expire: False\n",
	"  list: |\n",
		{ "Ref": "WorkstationUserName" },
		": ",
		{ "Ref": "WorkstationUserPasswd" },
	```