#define _CRT_SECURE_NO_WARNINGS
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>


#define TYPE_UNK	0
#define TYPE_TRD	1
#define TYPE_SCL	2
#define TYPE_HOB	3

#define EXIT_OK		0
#define EXIT_ERR	1

const char msgPrgName[]=     "trdtool.exe ";
const char msgVersion[]=     "TRDtool v2.21 by Shiru (shiru@mail.ru) 01'14\n\n";
//const char msgExtractOK[]=   "OK:  File from '%s' extracted to '%s'\n";
const char msgCantCreate[]=  "ERR: Can't create file '%s'!\n";
const char msgNotFoundIn[]=  "ERR: File '%s' not found in '%s'!\n";
const char msgNotFound[]=    "ERR: File '%s' not found!\n";
const char msgCatalogLine[]= "%s\t\t%3.3i sec (%5.5i bytes)\n";
//const char msgToHobetaOK[]=  "OK:  File '%s' converted to '%s'\n";
const char msgUnknownOper[]= "ERR: Unknown parameters set\n";
const char msgFileTooBig[]=  "ERR: File '%s' is too large!\n";
//const char msgSCLcreated[]=  "OK:  Empty SCL image '%s' successfully created\n";
//const char msgTRDcreated[]=  "OK:  Empty TRD image '%s' with name '%s' successfully created\n";
//const char msgMarkedErase[]= "OK:  File '%s' in image '%s' marked for erase\n";
//const char msgDeletedOK[]=   "OK:  %i file(s) from image '%s' deleted successfully\n";
const char msgDeletedNone[]= "WRN: No file(s) in image '%s' found to delete\n";
//const char msgMoveOK[]=      "OK:  MOVE operation for image '%s' completed successfully\n";
//const char msgShrinkOK[]=    "OK:  Image '%s' shrinked sucessfully\n";
const char msgNoRoomFC[]=    "ERR: No room in image '%s' for file '%s' (128 files max)!\n";
const char msgNoRoomSec[]=   "ERR: No room in image '%s' for file '%s' (2544 sectors max)!\n";
//const char msgFileAddOK[]=   "OK:  %i file(s) successfully added to image '%s'\n";
//const char msgHobetaAddOK[]= "OK:  Hobeta file '%s' added to image '%s'\n";
//const char msgBinaryAddOK[]= "OK:  Binary file '%s' added to image '%s' with name '%s'\n";



char lower_case(char sym)
{
	if(sym>='A'&&sym<='Z') sym+=32;
	return sym;
}



bool compare_name(unsigned char *data,const char *name)
{
	int aa;
	for(aa=0;aa<9;aa++)
	{
		if(lower_case(data[aa])!=name[aa]) return false;
	}
	return true;
}



void get_ext(const char *inname,char *ext)
{
	int aa,len,off,pp;

	len=strlen(inname);
	off=0;
	for(aa=len-1;aa>=0;aa--)
	{
		if(inname[aa]=='.')
		{
			off=aa+1;
			break;
		}
	}
	pp=0;
	while(off<len)
	{
		ext[pp++]=lower_case(inname[off++]);
	}
	ext[pp]=0;
}



void trdos_name(const char *inname,char *outname)
{
	int aa,len,pp;
	char ext[MAX_PATH];

	get_ext(inname,ext);

	memset(outname,32,11);
	len=strlen(inname);
	pp=0;
	for(aa=len-1;aa>=0;aa--)
	{
		if(inname[aa]=='\\'||inname[aa]=='/')
		{
			pp=aa+1;
			break;
		}
	}
	for(aa=0;aa<8;aa++)
	{
		if(pp==len) break;
		if(inname[pp]=='.') break;
		outname[aa]=inname[pp++];
	}
	for(aa=0;aa<3;aa++) outname[8+aa]=ext[aa];
}



int check_type(const char *filename)
{
	int type;
	char ext[MAX_PATH];

	get_ext(filename,ext);

	type=TYPE_UNK;
	if(ext[0]=='$')          type=TYPE_HOB;
	if(strcmp(ext,"trd")==0) type=TYPE_TRD;
	if(strcmp(ext,"scl")==0) type=TYPE_SCL;

	return type;
}



int trd_size(unsigned char *data,bool shrinked)
{
	if(shrinked)
	{
		return ((data[0x08e1]<<8)+(data[0x08e2]<<12));
	}
	else
	{
		return 655360;
	}
}




void about(void)
{
	printf(msgVersion);
	printf("%s\n- show this text\n",msgPrgName);
	printf("%s filename.trd (or .scl)\n- show disk catalog\n",msgPrgName);
	printf("%s filename.trd (or .scl) filename.ext (one or few names)\n- extract file(s) from disk image (with same name)\n",msgPrgName);
	printf("%s filename.$b (any hobeta file)\n- extract file from hobeta (with same name without $)\n",msgPrgName);
	printf("%s filename.ext (any file exlcude .scl/.trd/.$**)\n- convert file to hobeta\n",msgPrgName);
	printf("%s # filename.trd (or .scl)\n- create empty disk image\n",msgPrgName);
	printf("%s ! filename.trd (or .scl) filename.ext (one or few names)\n- delete file(s) from disk image\n",msgPrgName);
	printf("%s + filename.trd (or .scl) filename.ext (one or few names)\n- add file(s) to disk image\n",msgPrgName);
	printf("%s @ filename.trd (or .scl)\n- MOVE operation for disk image\n",msgPrgName);
	printf("%s $ filename.trd\n- shrink TRD-image\n");
}



int to_hobeta(char *argv[])
{
    FILE *file;
    int i,size,osize,sec,csum,nlen,elen;
    char name[MAX_PATH],extstr[MAX_PATH],trdosname[16];
    unsigned char *data,*buf;

	strcpy(name,argv[1]);
	nlen=strlen(name);
	get_ext(name,extstr);
	elen=strlen(extstr);

	file=fopen(name,"rb");
	if(!file)
	{
		printf(msgNotFound,name);
		return EXIT_ERR;
	}
	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

	trdos_name(name,trdosname);

	osize=(((size+255)>>8)<<8)+17;

	if(size>=65280)
	{
		printf(msgFileTooBig,argv[1]);
		free(data);
		return EXIT_ERR;
	}

	buf=(unsigned char*)malloc(osize);
	memset(buf,0,osize);
	memcpy(buf,trdosname,11);
	memcpy(&buf[17],data,size);

	sec=(size+255)>>8;
	buf[0x0b]=size&255;
	buf[0x0c]=size>>8;
	buf[0x0d]=sec>>8;
	buf[0x0e]=sec&255;

	csum=0;
	for(i=0;i<=14;csum=csum+(buf[i]*257)+i,i++);
	buf[0x0f]=csum&255;
	buf[0x10]=csum>>8;

	name[nlen-elen]='$';
	name[nlen-elen+1]=extstr[0];
	name[nlen-elen+2]=0;

	file=fopen(name,"wb");

	if(!file)
	{
		printf(msgCantCreate,name);
		free(buf);
		free(data);
		return EXIT_ERR;
	}

	fwrite(buf,osize,1,file);
	fclose(file);

	free(buf);
	free(data);

	//printf(msgToHobetaOK,argv[1],name);

	return EXIT_OK;
}



int from_hobeta(char *argv[])
{
    FILE *file;
    int nlen,elen,size;
    char name[MAX_PATH],extstr[MAX_PATH];
    unsigned char *data;

	strcpy(name,argv[1]);
	nlen=strlen(name);
	get_ext(name,extstr);
	elen=strlen(extstr);

	file=fopen(name,"rb");
	if(!file)
	{
		printf(msgNotFound,name);
		return EXIT_ERR;
	}
	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

	name[nlen-elen]=name[nlen-elen+1];
	name[nlen-elen+1]=0;
	file=fopen(name,"wb");

	if(file)
    {
        size=data[0x0b]+data[0x0c]*256;
		fwrite(&data[17],size,1,file);
		fclose(file);
		//printf(msgExtractOK,argv[1],name);
	}
	else
	{
		printf(msgCantCreate,name);
	}

	free(data);

	return EXIT_OK;
}



int scl_catalog(char *argv[])
{
    FILE *file;
    int i,j,nlen,pp,it,len,size;
    char name[MAX_PATH];
    unsigned char *data;

    strcpy(name,argv[1]);
    nlen=strlen(name);

    file=fopen(name,"rb");
    if(!file)
    {
    	printf(msgNotFound,name);
    	return EXIT_ERR;
    }
    fseek(file,0,SEEK_END);
    size=ftell(file);
    fseek(file,0,SEEK_SET);
    data=(unsigned char*)malloc(size);
    fread(data,size,1,file);
    fclose(file);

	pp=9;
	data[2301]=0;

	printf("\nFilename: %s\tFiles: %i\n\n",name,data[8]);

	name[8]='.';
	name[12]=0;

	for(i=0;i<data[8];i++)
	{
		len=data[pp+11]+(data[pp+12]<<8);
		for(j=0;j<8;j++)
		{
			it=data[pp+j];
			if(it<32||it>127) it='~';
			name[j]=it;
		}
		name[8]='.';
		if(data[pp+9]>32&&data[pp+9]<128&&data[pp+10]>32&&data[pp+10]<128)
		{
			memcpy(&name[9],&data[pp+8],3);
		}
		else
		{
			name[9]=data[pp+8];
			name[10]=' ';
			name[11]=' ';
		}
		printf(msgCatalogLine,name,data[pp+13],len);
		pp+=14;
	}

	free(data);

	return EXIT_OK;
}



int trd_catalog(char *argv[])
{
    FILE *file;
    int i,j,nlen,elen,size,len,it,pp;
    char name[MAX_PATH],extstr[MAX_PATH];
    unsigned char *data;

    strcpy(name,argv[1]);
    nlen=strlen(name);
    get_ext(name,extstr);
    elen=strlen(extstr);

    file=fopen(name,"rb");
    if(!file)
    {
    	printf(msgNotFound,name);
    	return EXIT_ERR;
    }
    fseek(file,0,SEEK_END);
    size=ftell(file);
    fseek(file,0,SEEK_SET);
    data=(unsigned char*)malloc(size);
    fread(data,size,1,file);
    fclose(file);

	pp=0;
	data[2301]=0;
	name[8]='.';
	name[12]=0;

	printf("Disk name: %s\t",&data[2293]);
	printf("Files: %i\t",data[2276]-data[2292]);
	printf("Deleted: %i\t",data[2292]);
	printf("Free sectors: %i\n\n",data[2277]+(data[2278]<<8));

	for(i=0;i<data[2276];i++)
	{
		len=data[pp+11]+(data[pp+12]<<8);
		for(j=0;j<8;j++)
		{
			it=data[pp+j];
			if(it<32||it>127) it='~';
			name[j]=it;
		}
		name[8]='.';
		if(data[pp+9]>32&&data[pp+9]<128&&data[pp+10]>32&&data[pp+10]<128)
		{
			memcpy(&name[9],&data[pp+8],3);
		}
		else
		{
			name[9]=data[pp+8];
			name[10]=' ';
			name[11]=' ';
		}
		printf(msgCatalogLine,name,data[pp+13],len);
		pp+=16;
	}

	free(data);

	return EXIT_OK;
}



int scl_add(char *argv[],int argc)
{
    FILE *file;
    int i,size,len,pp,osize,off,dcnt,cnt,sec,csum;
    char name[MAX_PATH],extstr[MAX_PATH],trdosname[16];
    unsigned char *data,*buf;

	strcpy(name,argv[2]);

	file=fopen(name,"rb");

	if(!file)
	{
		printf(msgNotFound,name);
		return EXIT_ERR;
	}

	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

	osize=size;
	dcnt=0;

	for(cnt=3;cnt<argc;cnt++)
	{
		if(data[8]>=128)
		{
			printf(msgNoRoomFC,argv[cnt],argv[2]);
			break;
		}

		sec=0;

		pp=9+13;//sector field of the first file

		for(i=0;i<data[8];i++)
		{
			sec+=data[pp];
			pp+=14;
		}

		get_ext(argv[cnt],extstr);

		file=fopen(argv[cnt],"rb");

		if(!file)
		{
			printf(msgNotFound,argv[cnt]);
			continue;
		}

		fseek(file,0,SEEK_END);
		size=ftell(file);

		if(extstr[0]=='$')//adding hobeta file
		{
			fseek(file,0,SEEK_SET);
			buf=(unsigned char*)malloc(size);
			fread(buf,1,size,file);
			fclose(file);

			size=(buf[0x0d]<<8)+buf[0x0e];

			if(buf[0x0d]!=0||size+sec>2544)
			{
				printf(msgNoRoomSec,argv[2],argv[cnt]);
				free(buf);
				continue;
			}

			len=osize;
			osize=osize+(size<<8)+14;
			data=(unsigned char*)realloc(data,osize);
			off=9+data[8]*14;
			memcpy(&data[off+14],&data[off],len-off);
			buf[0x0d]=buf[0x0e];
			memcpy(&data[off],buf,14);
			memcpy(&data[len+14-4],&buf[17],buf[0x0e]<<8);
			free(buf);

			//printf(msgHobetaAddOK,argv[cnt],argv[2]);
		}
		else//adding binary file
		{
			if(size>=65280)
			{
				fclose(file);
				printf(msgFileTooBig,argv[cnt]);
				continue;
			}
			if(sec+((size+255)>>8)>2544)
			{
				fclose(file);
				printf(msgNoRoomSec,argv[2],argv[cnt]);
				continue;
			}

			fseek(file,0,SEEK_SET);
			buf=(unsigned char*)malloc(size);
			fread(buf,1,size,file);
			fclose(file);

			trdos_name(argv[cnt],trdosname);

			len=osize;
			osize=osize+(((size+255)>>8)<<8)+14;
			data=(unsigned char*)realloc(data,osize);
			pp=9+data[8]*14;
			memcpy(&data[pp+14],&data[pp],len-pp);
			if(trdosname[8]=='c') trdosname[8]='C';
			memcpy(&data[pp],trdosname,11);
			data[pp+0x0b]=size&255;
			data[pp+0x0c]=size>>8;
			data[pp+0x0d]=(size+255)>>8;
			memset(&data[len+14-4],0,osize-(len+14-4));
			memcpy(&data[len+14-4],buf,size);
			free(buf);

			trdosname[0x0c]=0;
			trdosname[0x0b]=trdosname[0x0a];
			trdosname[0x0a]=trdosname[0x09];
			trdosname[0x09]=trdosname[0x08];
			trdosname[0x08]='.';
			//printf(msgBinaryAddOK,argv[cnt],argv[2],trdosname);
		}

		data[8]++;
		dcnt++;
	}

	if(dcnt>0)
	{
		csum=0;
		for(i=0;i<osize-4;i++) csum+=data[i];
		data[osize-4]=csum&0xff;
		data[osize-3]=(csum>>8)&0xff;
		data[osize-2]=(csum>>16)&0xff;
		data[osize-1]=(csum>>24)&0xff;

		file=fopen(argv[2],"wb");
		if(!file)
		{
			free(data);
			printf(msgCantCreate,argv[2]);
			return EXIT_ERR;
		}
		fwrite(data,osize,1,file);
		fclose(file);
		//printf(msgFileAddOK,dcnt,argv[2]);
	}

	free(data);

    return EXIT_OK;
}



int trd_add(char *argv[],int argc)
{
    FILE *file;
    int size,len,pp,dcnt,cnt,sec;
    char name[MAX_PATH],extstr[MAX_PATH],trdosname[16];
    unsigned char *data,*buf;
    bool shrinked;

    strcpy(name,argv[2]);

    file=fopen(name,"rb");

    if(!file)
    {
    	printf(msgNotFound,name);
    	return EXIT_ERR;
    }

    fseek(file,0,SEEK_END);
    size=ftell(file);
    fseek(file,0,SEEK_SET);
    data=(unsigned char*)malloc(size);
    fread(data,size,1,file);
    fclose(file);

	dcnt=0;

	if(size==655360)
	{
		shrinked=false;
	}
	else
	{
		shrinked=true;
		data=(unsigned char*)realloc(data,655360);
		memset(&data[size],0,655360-size);
	}

	sec=2544-(data[2277]+(data[2278]<<8));

	for(cnt=3;cnt<argc;cnt++)
	{
		if(data[0x08e4]>=128)
		{
			printf(msgNoRoomFC,argv[2],argv[cnt]);
			break;
		}

		get_ext(argv[cnt],extstr);

		file=fopen(argv[cnt],"rb");
		if(!file)
		{
			printf(msgNotFound,argv[cnt]);
			continue;
		}
		fseek(file,0,SEEK_END);
		size=ftell(file);

		if(extstr[0]=='$')//adding a Hobeta file
		{
			fseek(file,0,SEEK_SET);
			buf=(unsigned char*)malloc(size);
			fread(buf,1,size,file);
			fclose(file);

			size=(buf[0x0d]<<8)+buf[0x0e];
			if(buf[0x0d]!=0||size+sec>2544)
			{
				printf(msgNoRoomSec,argv[2],argv[cnt]);
				free(buf);
				continue;
			}

			buf[0x0d]=buf[0x0e];
			pp=data[0x08e4]<<4;
			memcpy(&data[pp],buf,14);
			data[pp+0x0e]=data[0x08e1];
			data[pp+0x0f]=data[0x08e2];
			pp=(data[0x08e1]<<8)+(data[0x08e2]<<12);
			memcpy(&data[pp],&buf[17],buf[0x0d]<<8);

			sec=buf[0x0d];

			//printf(msgHobetaAddOK,argv[cnt],argv[2]);
		}
		else//adding a binary file
		{
			if(size>=65280)
			{
				fclose(file);
				printf(msgFileTooBig,argv[cnt]);
				continue;
			}
			if(sec+((size+255)>>8)>2544)
			{
				fclose(file);
				printf(msgNoRoomSec,argv[2],argv[cnt]);
				continue;
			}

			fseek(file,0,SEEK_SET);
			buf=(unsigned char*)malloc(size);
			fread(buf,1,size,file);
			fclose(file);

			trdos_name(argv[cnt],trdosname);

			pp=data[0x08e4]<<4;

			if(trdosname[8]=='c') trdosname[8]='C';

			memcpy(&data[pp],trdosname,11);

			data[pp+0x0b]=size&255;
			data[pp+0x0c]=size>>8;
			data[pp+0x0d]=(size+255)>>8;
			data[pp+0x0e]=data[0x08e1];
			data[pp+0x0f]=data[0x08e2];
			pp=(data[0x08e1]<<8)+(data[0x08e2]<<12);
			memset(&data[pp],0,data[pp+0x0d]<<8);
			memcpy(&data[pp],buf,size);

			trdosname[0x0c]=0;
			trdosname[0x0b]=trdosname[0x0a];
			trdosname[0x0a]=trdosname[0x09];
			trdosname[0x09]=trdosname[0x08];
			trdosname[0x08]='.';
			//printf(msgBinaryAddOK,argv[cnt],argv[2],trdosname);
			sec=(size+255)>>8;//trefi's fix
		}

		len=(data[0x08e5]+(data[0x08e6]<<8))-sec;

		data[0x08e5]=len&255;
		data[0x08e6]=len>>8;

		sec+=(data[0x08e2]<<4)+data[0x08e1];//trefi's fix

		data[0x08e1]=(sec&15);
		data[0x08e2]=(sec>>4);
		data[0x08e4]++;

		dcnt++;
	}

	if(dcnt>0)
	{
		file=fopen(argv[2],"wb");
		if(!file)
		{
			free(data);
			printf(msgCantCreate,argv[2]);
			return EXIT_ERR;
		}
		fwrite(data,trd_size(data,shrinked),1,file);
		fclose(file);
		//printf(msgFileAddOK,dcnt,argv[2]);
	}

	free(data);

    return EXIT_OK;
}



int scl_del(char *argv[],int argc)
{
    FILE *file;
    int i,size,len,pp,pd,osize,dcnt,cnt,csum,soff,doff;
    char name[MAX_PATH];
    char ext;
    unsigned char *data,*buf;

	strcpy(name,argv[2]);
	file=fopen(name,"rb");
	if(!file)
	{
		printf(msgNotFound,name);
		return EXIT_ERR;
	}
	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

	dcnt=0;
	for(cnt=3;cnt<argc;cnt++)
	{
		strcpy(name,(char*)argv[cnt]);
		pp=(int)strlen(name);
		for(i=0;i<(int)strlen(name);i++)
		{
			name[i]=lower_case(name[i]);
			if(name[i]=='.') pp=i;
		}
		ext=name[pp+1];
		for(i=pp;i<10;i++) name[i]=' ';
		name[8]=ext;
		name[9]=0;

		pp=9;
		for(i=0;i<data[8];i++)
		{
			if(compare_name(&data[pp],name))
			{
				//printf(msgMarkedErase,argv[cnt],argv[2]);
				data[pp]=0;
				dcnt++;
				break;
			}
			pp+=14;
		}
		if(pp==(data[8]*14+9)) printf(msgNotFoundIn,argv[cnt],argv[2]);
	}

	if(dcnt>0)
	{
		buf=(unsigned char*)malloc(size);

		memcpy(buf,"SINCLAIR",8);
		buf[8]=data[8]-dcnt;

		soff=data[8]*14+9;
		doff=buf[8]*14+9;
		pp=9;
		pd=9;

		for(i=0;i<data[8];i++)
		{
			len=data[pp+13]<<8;
			if(data[pp]>0)
			{
				memcpy(&buf[pd],&data[pp],14);
				pd+=14;
				memcpy(&buf[doff],&data[soff],len);
				doff+=len;
			}
			pp+=14;
			soff+=len;
		}

		csum=0;
		for(i=0;i<doff;i++) csum+=buf[i];
		buf[doff+0]=csum&0xff;
		buf[doff+1]=(csum>>8)&0xff;
		buf[doff+2]=(csum>>16)&0xff;
		buf[doff+3]=(csum>>24)&0xff;

		osize=doff+4;

		file=fopen(argv[2],"wb");
		if(!file)
		{
			free(data);
			free(buf);
			printf(msgCantCreate,argv[2]);
			return EXIT_ERR;
		}
		fwrite(buf,osize,1,file);
		fclose(file);
		free(buf);

		//printf(msgDeletedOK,dcnt,argv[2]);
	}
	else
	{
		printf(msgDeletedNone,argv[2]);
		free(data);
		return EXIT_ERR;
	}

	free(data);

    return EXIT_OK;
}



int trd_del(char *argv[],int argc)
{
    FILE *file;
    int i,size,pp,pd,dcnt,cnt,sec,soff,doff,all,del;
    char name[MAX_PATH];
    char ext;
    unsigned char *data,*buf;
    bool shrinked;

	strcpy(name,argv[2]);
	file=fopen(name,"rb");
	if(!file)
	{
		printf(msgNotFound,name);
		return EXIT_ERR;
	}
	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

    dcnt=0;
    if(size==655360) shrinked=false; else shrinked=true;

    for(cnt=3;cnt<argc;cnt++)
    {
    	strcpy(name,(char*)argv[cnt]);
    	pp=(int)strlen(name);
    	for(i=0;i<(int)strlen(name);i++)
    	{
    		name[i]=lower_case(name[i]);
    		if(name[i]=='.') pp=i;
    	}
    	ext=name[pp+1];
    	for(i=pp;i<10;i++) name[i]=' ';
    	name[8]=ext;
    	name[9]=0;

    	pp=0;
    	for(i=0;i<128;i++)
    	{
    		if(compare_name(&data[pp],name)) break;
    		pp+=16;
    	}

    	if(pp==2048)
    	{
    		printf(msgNotFoundIn,argv[cnt],argv[2]);
    		continue;
    	}

    	data[pp]=2;
    	//printf(msgMarkedErase,argv[cnt],argv[2]);
    	dcnt++;
    }

    if(dcnt>0)
    {
    	buf=(unsigned char*)malloc(655360);
    	memset(buf,0,655360);
    	memcpy(&buf[0x0800],&data[0x0800],0x0800);

    	pp=0;
    	pd=0;
    	doff=0x1000;
    	all=0;
    	del=0;
    	sec=2544;

    	for(i=0;i<128;i++)
    	{
    		if(data[pp]!=2&&data[pp]!=0)
    		{
    			memcpy(&buf[pd],&data[pp],0x10);
    			buf[pd+14]=(doff/256)&15;
    			buf[pd+15]=doff/256/16;
    			pd+=0x10;
    			soff=(data[pp+15]<<12)+(data[pp+14]<<8);
    			memcpy(&buf[doff],&data[soff],data[pp+0x0d]<<8);
    			doff+=(data[pp+0x0d]<<8);
    			sec-=data[pp+0x0d];
    			all++;
    			if(data[pp]==1) del++;
    		}
    		pp+=16;
    	}

    	buf[0x08e1]=(doff&0x0f00)>>8;
    	buf[0x08e2]=(doff&0xff000)>>12;
    	buf[0x08e4]=all;
    	buf[0x08e5]=sec&255;
    	buf[0x08e6]=sec>>8;
    	buf[0x08f4]=del;

    	file=fopen(argv[2],"wb");
    	if(!file)
    	{
    		free(data);
    		free(buf);
    		printf(msgCantCreate,argv[2]);
    		return EXIT_ERR;
    	}
    	fwrite(buf,trd_size(buf,shrinked),1,file);
    	fclose(file);
    	free(buf);

    	//printf(msgDeletedOK,dcnt,argv[2]);
    }
    else
    {
    	printf(msgDeletedNone,argv[2]);
    	free(data);
    	return EXIT_ERR;
    }

    free(data);

    return EXIT_OK;
}



int scl_create(char *argv[])
{
    FILE *file;
    int i,csum;
    char name[MAX_PATH];
    unsigned char *data;

	strcpy(name,argv[2]);

	file=fopen(name,"wb");
	if(!file)
	{
		printf(msgCantCreate,name);
		return EXIT_ERR;
	}

	data=(unsigned char*)malloc(13);

	memcpy(data,"SINCLAIR",8);
	data[8]=0;

	csum=0;
	for(i=0;i<9;i++) csum+=data[i];
	data[9]=csum&0xff;
	data[10]=(csum>>8)&0xff;
	data[11]=(csum>>16)&0xff;
	data[12]=(csum>>24)&0xff;

	fwrite(data,13,1,file);
	fclose(file);

	//printf(msgSCLcreated,name);

	free(data);

    return EXIT_OK;
}



int trd_create(char *argv[])
{
    FILE *file;
    int i;
    char name[MAX_PATH],trdosname[16];
    unsigned char *data;

	strcpy(name,argv[2]);

	file=fopen(name,"wb");
	if(!file)
	{
		printf(msgCantCreate,name);
		return EXIT_ERR;
	}

	trdos_name(name,trdosname);

	data=(unsigned char*)malloc(655360);
	memset(data,0,655360);
	data[0x08e2]=0x01;
	data[0x08e3]=0x16;
	data[0x08e5]=0xf0;
	data[0x08e6]=0x09;
	data[0x08e7]=0x10;
	for(i=0;i<9;i++) data[0x08ea+i]=0x20;
	memcpy(&data[0x08f5],trdosname,8);
	trdosname[8]=0;

	fwrite(data,655360,1,file);
	fclose(file);

	//printf(msgTRDcreated,name,trdosname);

	free(data);

    return EXIT_OK;
}



int scl_move(char *argv[])
{
    FILE *file;
    int i,size,len,pp,pd,osize,csum,soff,doff,all;
    char name[MAX_PATH];
    unsigned char *data,*buf;

	strcpy(name,argv[2]);
	file=fopen(name,"rb");
	if(!file)
	{
		printf(msgNotFound,name);
		return EXIT_ERR;
	}
	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

	buf=(unsigned char*)malloc(size);

	memcpy(buf,"SINCLAIR",8);

	all=0;
	pp=0;
	for(i=0;i<data[8];i++)
	{
		if(data[pp]>1) all++;
		pp+=14;
	}
	buf[8]=all;

	soff=data[8]*14+9;
	doff=buf[8]*14+9;
	pp=9;
	pd=9;

	for(i=0;i<data[8];i++)
	{
		len=data[pp+13]<<8;
		if(data[pp]>1)
		{
			memcpy(&buf[pd],&data[pp],14);
			pd+=14;
			memcpy(&buf[doff],&data[soff],len);
			doff+=len;
		}
		pp+=14;
		soff+=len;
	}

	csum=0;
	for(i=0;i<doff;i++) csum+=buf[i];
	buf[doff+0]=csum&0xff;
	buf[doff+1]=(csum>>8)&0xff;
	buf[doff+2]=(csum>>16)&0xff;
	buf[doff+3]=(csum>>24)&0xff;

	osize=doff+4;

	file=fopen(argv[2],"wb");
	if(!file)
	{
		free(data);
		free(buf);
		printf(msgCantCreate,argv[2]);
		return EXIT_ERR;
	}
	fwrite(buf,osize,1,file);
	fclose(file);
	free(buf);

	//printf(msgMoveOK,argv[2]);

	free(data);

    return EXIT_OK;
}



int trd_move(char *argv[])
{
    FILE *file;
    int i,size,pp,pd,sec,soff,doff,all,del;
    char name[MAX_PATH];
    unsigned char *data,*buf;
    bool shrinked;

    strcpy(name,argv[2]);
    file=fopen(name,"rb");
    if(!file)
    {
    	printf(msgNotFound,name);
    	return EXIT_ERR;
    }
    fseek(file,0,SEEK_END);
    size=ftell(file);
    fseek(file,0,SEEK_SET);
    data=(unsigned char*)malloc(size);
    fread(data,size,1,file);
    fclose(file);

	if(size==655360) shrinked=false; else shrinked=true;

	buf=(unsigned char*)malloc(655360);
	memset(buf,0,655360);
	memcpy(&buf[0x0800],&data[0x0800],0x0800);

	pp=0;
	pd=0;
	doff=0x1000;
	all=0;
	del=0;
	sec=2544;
	for(i=0;i<128;i++)
	{
		if(data[pp]>1)
		{
			memcpy(&buf[pd],&data[pp],0x10);
			buf[pd+14]=(doff/256)&15;
			buf[pd+15]=doff/256/16;
			pd+=0x10;
			soff=(data[pp+15]<<12)+(data[pp+14]<<8);
			memcpy(&buf[doff],&data[soff],data[pp+0x0d]<<8);
			doff+=(data[pp+0x0d]<<8);
			sec-=data[pp+0x0d];
			all++;
			if(data[pp]==1) del++;
		}
		pp+=16;
	}

	buf[0x08e1]=(doff&0x0f00)>>8;
	buf[0x08e2]=(doff&0xff000)>>12;
	buf[0x08e4]=all;
	buf[0x08e5]=sec&255;
	buf[0x08e6]=sec>>8;
	buf[0x08f4]=del;

	file=fopen(argv[2],"wb");
	if(!file)
	{
		free(data);
		free(buf);
		printf(msgCantCreate,argv[2]);
		return EXIT_ERR;
	}
	fwrite(buf,trd_size(buf,shrinked),1,file);
	fclose(file);
	free(buf);

	//printf(msgMoveOK,argv[2]);

	free(data);

    return EXIT_OK;
}



int trd_shrink(char *argv[],int argc)
{
    FILE *file;
    int size;
    char name[MAX_PATH];
    unsigned char *data;

    strcpy(name,argv[2]);
    if(argc!=3||check_type(name)!=TYPE_TRD)//wrong number of parameters or file type
    {
    	printf(msgUnknownOper);
    	return EXIT_ERR;
    }

    file=fopen(name,"rb");
    if(!file)
    {
    	printf(msgNotFound,name);
    	return EXIT_ERR;
    }

    fseek(file,0,SEEK_END);
    size=ftell(file);
    fseek(file,0,SEEK_SET);
    data=(unsigned char*)malloc(size);
    fread(data,size,1,file);
    fclose(file);

    size=(data[0x08e1]<<8)+(data[0x08e2]<<12);

    file=fopen(name,"wb");
    if(!file)
    {
    	free(data);
    	printf(msgCantCreate,name);
    	return EXIT_ERR;
    }
    fwrite(data,size,1,file);
    fclose(file);

    //printf(msgShrinkOK,argv[2]);

    free(data);

    return EXIT_OK;
}



int scl_extract(char *argv[],int argc)
{
    FILE *file;
    int i,size,len,pp,cnt,off;
    char name[MAX_PATH];
    char ext;
    unsigned char *data;

	file=fopen(argv[1],"rb");
	if(!file)
	{
		printf(msgNotFound,argv[1]);
		return EXIT_ERR;
	}
	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

	for(cnt=2;cnt<argc;cnt++)
	{
		strcpy(name,(char*)argv[cnt]);
		pp=(int)strlen(name);
		for(i=0;i<(int)strlen(name);i++)
		{
			name[i]=lower_case(name[i]);
			if(name[i]=='.') pp=i;
		}
		ext=name[pp+1];
		for(i=pp;i<10;i++) name[i]=' ';
		name[8]=ext;
		name[9]=0;

		pp=9;
		off=9+data[8]*14;
		for(i=0;i<data[8];i++)
		{
			if(data[pp]<32) data[pp]='~';
			if(compare_name(&data[pp],name)) break;
			off+=(data[pp+13]<<8);
			pp+=14;
		}

		if(pp==(9+data[8]*14))
		{
			printf(msgNotFoundIn,argv[cnt],argv[1]);
			continue;
		}

		len=data[pp+11]+(data[pp+12]<<8);
		if(len==0) len=(data[pp+13]<<8);

		file=fopen(argv[cnt],"wb");
		if(file)
		{
			fwrite(&data[off],len,1,file);
			fclose(file);
			//printf(msgExtractOK,argv[1],argv[cnt]);
		}
		else
		{
			printf(msgCantCreate,argv[cnt]);
		}
	}

	free(data);

    return EXIT_OK;
}



int trd_extract(char *argv[],int argc)
{
    FILE *file;
    int i,size,len,pp,cnt,off;
    char name[MAX_PATH];
    char ext;
    unsigned char *data;

	file=fopen(argv[1],"rb");
	if(!file)
	{
		printf(msgNotFound,argv[1]);
		return EXIT_ERR;
	}
	fseek(file,0,SEEK_END);
	size=ftell(file);
	fseek(file,0,SEEK_SET);
	data=(unsigned char*)malloc(size);
	fread(data,size,1,file);
	fclose(file);

	for(cnt=2;cnt<argc;cnt++)
	{
		strcpy(name,(char*)argv[cnt]);
		pp=(int)strlen(name);
		for(i=0;i<(int)strlen(name);i++)
		{
			name[i]=lower_case(name[i]);
			if(name[i]=='.') pp=i;
		}
		ext=name[pp+1];
		for(i=pp;i<10;i++) name[i]=' ';
		name[8]=ext;
		name[9]=0;

		pp=0;
		for(i=0;i<128;i++)
		{
			if(data[pp]<32) data[pp]='~';
			if(compare_name(&data[pp],name)) break;
			pp+=16;
		}

		if(pp==2048)
		{
			printf(msgNotFoundIn,argv[cnt],argv[1]);
			continue;
		}

		off=(data[pp+14]<<8)+(data[pp+15]<<12);
		len=data[pp+11]+(data[pp+12]<<8);
		if(len==0) len=(data[pp+13]<<8);

		file=fopen(argv[cnt],"wb");
		if(file)
		{
			fwrite(&data[off],len,1,file);
			fclose(file);
			//printf(msgExtractOK,argv[1],argv[cnt]);
		}
		else
		{
			printf(msgCantCreate,argv[cnt]);
		}
	}

	free(data);

    return EXIT_OK;
}



int main(int argc, char* argv[])
{
	switch(argc)
	{
	case 0:
	case 1://no parameters, show about
		about();
		return EXIT_OK;

	case 2://single parameter, show catalog for TRD and SCL, convert from/to Hobeta for other types
		{
			switch(check_type(argv[1]))
			{
			case TYPE_UNK://convert a file to Hobeta
                return to_hobeta(argv);

			case TYPE_HOB://convert a file from Hobeta
                return from_hobeta(argv);

			case TYPE_SCL://show SCL catalog
                return scl_catalog(argv);

			case TYPE_TRD://show TRD catalog
                return trd_catalog(argv);
			}
		}
		break;

	default:

		if(strlen(argv[1])==1)
		{
			switch(argv[1][0])
			{
			case '+'://adding files
				{
					switch(check_type(argv[2]))
					{
					case TYPE_SCL://add a file into SCL
                        return scl_add(argv,argc);

    				case TYPE_TRD://add a file into TRD
                        return trd_add(argv,argc);
    				}
    			}
                break;

			case '!'://deleting files
				{
					switch(check_type(argv[2]))
					{
					case TYPE_SCL://delete a file from SCL
                        return scl_del(argv,argc);

					case TYPE_TRD://delete a file from TRD
                        return trd_del(argv,argc);
				    }
				}
				break;

			case '#'://create empty disk image
				if(argc==3)
                {
                    switch(check_type(argv[2]))
                    {
                    case TYPE_SCL://create empty SCL image
                        return scl_create(argv);

                    case TYPE_TRD://create empty TRD image
                        return trd_create(argv);
                    }
				}
				break;

			case '@'://MOVE operation
				if(argc==3)
                {
					switch(check_type(argv[2]))
					{
					case TYPE_SCL://MOVE for SCL
                        return scl_move(argv);

					case TYPE_TRD://MOVE for TRD
                        return trd_move(argv);
			        }
				}
				break;

			case '$'://shrink TRD
                return trd_shrink(argv,argc);
			}
		}
		else//extracting files
		{
			switch(check_type(argv[1]))
			{
			case TYPE_SCL://extract files from SCL
                return scl_extract(argv,argc);

			case TYPE_TRD://extract files from TRD
                return trd_extract(argv,argc);
			}
		}
	}

	printf(msgUnknownOper);
	return EXIT_ERR;
}
