# var2wormtable
An Arvados pipeline template, var files to wormtable (for use in http://github.com/ga4gh/server circa late-2014) 

## Overview

These set of shell scripts are combined in a way (described by the pipeline template for running automatically in Arvados) that goes from a set of VAR files to a set of wormtable files suitable for import into the GA4GH reference server implementation circa late 2014. 

## Details

###  vartovcf-2.sh

This file uses cgatools mkvcf to convert the VAR files into VCF files.
http://cgatools.sourceforge.net/docs/1.6.0/cgatools-command-line-reference.html#mkvcf

Input: a directory with a lot of VAR files in it, ending in .tsv.bz2, e.g. hu132B5C.tsv.bz2

Output: a directory with a lot of VCF files in it, ending in .vcf, e.g. hu132B5C.vcf

### mergevcf.sh

This file merges the directory of VCF files into a single VCF file by discarding all the headers except for the header from the first file, and then concatenating all the files.

Input: a directory with a lot of VCF files in it

Output: a single VCF file, i.e. mergedvcf.vcf

### makewormtable.sh

Input: mergedvcf.vcf

Output: a directory with wormtable files

* index_CHROM+ID.db
* index_CHROM+ID.xml
* index_CHROM+POS.db
* index_CHROM+POS.xml
* table.dat
* table.db
* table.xml


### pipelinetemplate.json

The Arvados pipeline template that orchestrates the above set of steps.

For more information, see:

* https://arvados.org/
* http://doc.arvados.org/user/tutorials/running-external-program.html
* https://arvados.org/projects/arvados/wiki/Port_a_Pipeline/

### docker image

This relies on the nancy/cgatools-womrtable Docker Image, which may also be found at
https://registry.hub.docker.com/u/nouyang/cgatools-wormtable/

To set up your own docker image, see the following steps.

#### Install Docker

	$ sudo apt-get install docker.io
	$ sudo groupadd docker
	$ sudo gpasswd -a $USER docker #in my case, I replace $USER with "nancy"
	$ sudo service docker restart
	$ exec su -l $USER #if you don't want to login+out or spawn a new shell

#### Create new image and enter it

	$ docker pull arvados/jobs
	$ docker run -ti arvados/jobs /bin/bash
	root@4fa648c759f3:/# apt-get update

#### Install cgatools (for mkvcf)

cgatools is not super-pleasant to install. Here is my step-by-step for ubuntu 14.04 (trusty) / debian 7.8 (wheezy).

http://cgatools.sourceforge.net/
http://cgatools.sourceforge.net/docs/1.1.0/cgatools-install.pdf

	cd /home
	mkdir nrw
	cd nrw
	mkdir src
	mkdir local
	mkdir local/bin
	mkdir local/share
	mkdir local/share/cgatools-1.8.0/
	mkdir local/share/cgatools-1.8.0/doc
	mkdir data
	mkdir data/ref
	apt-get install cmake
	curl -O "http://hivelocity.dl.sourceforge.net/project/cgatools/1.8.0/cgatools-1.8.0.1-linux_binary-x86_64.tar.gz"
	tar -xvf cgatools-1.8.0.1-linux_binary-x86_64.tar.gz
	cp cgatools-1.8.0.1-linux_binary-x86_64/bin/cgatools /home/nrw/bin
	cp cgatools-1.8.0.1-linux_binary-x86_64/share/cgatools-1.8.0/cgatools-1.8.0.1-docs/* /home/nrw/local/share/cgatools-1.8.0/doc

	vi ~/.bashrc
		export PATH=$PATH:/home/nrw/local/bin

	source ~/.bashrc
	hash -r

	root@4fa648c759f3:/# cgatools #yep, this works! 
		cgatools version 1.8.0 build 1
		(...)

	cd /home/nrw/data
	curl -O ftp.completegenomics.com/ReferenceFiles/build37.crr  #this step takes about an hour.

#### Install wormtable (for vcf2w

	:/# apt-get install libdb-dev
	:/# pip install wormtable

	:/# which vcf2wt #check it's installed in the correct place
	/usr/local/bin/vcf2wt


#### Exit docker image and save it

	root@4fa648c759f3:/# exit
	$ docker commit 4fa648c759f3 nancy/cgatools-wormtable

## Key "Parameters" used

In vartovcf-2.sh line 33:

    /home/nrw/local/bin/cgatools mkvcf --beta --genome-root $DIR2 --source-names masterVar --reference /home/nrw/data/ref/build37.crr --output $OUTDIR/$shortfilename.vcf --field-names GT

In makewormtable.sh line 9:

vcf2wt $INDIR/mergedvcf.vcf --truncate --quiet -tf $OUTDIR


