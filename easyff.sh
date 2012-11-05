#!/bin/sh

## Colors
RED='\033[31m'
BLUE='\033[34m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
D="\033[0m"
## End Colors

echo -e "$GREEN=> Digite o nome do arquivo:$D "
read FI_NAME

echo -e "$GREEN=> Digite o nome de saída do arquivo, incluindo extensão:$D "
read FO_NAME

echo -e "$GREEN=> [VIDEO] Digite o frame rate(Padrão: 29 FPS):$D "
read FPS

if [ -z $FPS ];then 
	echo -e "$YELLOW==> Frame rate não definido usando Padrão: 29 FPS$D\n"
	FPS=29
fi

ask_vsize(){
	echo -e "$GREEN=> [VIDEO] Digite a resolução do video(Padrão: VGA = 640x480) (Digite 'h' para ver opções):$D "
	read V_SIZE
	
	vsize_help(){
	echo -e "$CYAN
sqcif\t= 128x96\tqcif\t= 176x144\tcif\t= 352x288
4cif\t= 704x576\t16cif\t= 1408x1152\tqqvga\t= 160x120
qvga\t= 320x240\tvga\t= 640x480\tsvga\t= 800x600
xga\t= 1024x768\tuxga\t= 1600x1200\tqxga\t= 2048x1536
sxga\t= 1280x1024\tqsxga\t= 2560x2048\thsxga\t= 5120x4096
wvga\t= 852x480\twxga\t= 1366x768\twsxga\t= 1600x1024
wuxga\t= 1920x1200\twoxga\t= 2560x1600\twqsxga\t= 3200x2048
wquxga\t= 3840x2400\twhsxga\t= 6400x4096\twhuxga\t= 7680x4800
cga\t= 320x200\tega\t= 640x350\thd480\t= 852x480
hd720\t= 1280x720\thd1080\t= 1920x1080
$D
$GREEN==> [DICA] Você pode usar valores customizados colocando-os no formato WIDTHxHEIGHT$D"
	}
	
	if [[ $V_SIZE == 'h' || $V_SIZE == 'H' ]]; then
		vsize_help
		ask_vsize
	elif [ -z $V_SIZE ]; then 
		echo -e "$YELLOW==> Resolução não definida usando Padrão: VGA = 640x480$D\n"
		V_SIZE='vga'
	else 
		echo -e "$YELLOW==> Usando ${V_SIZE} como resolução.$D"
fi
}

ask_vsize

echo -e "$GREEN=> [VIDEO] Digite a taxa de bits por segundo(Padrão: 256k):$D "
read V_KBPS

if [ -z $V_KBPS ]; then
	V_KBPS='256k'
fi

echo -e "$GREEN=> [AUDIO] Digite a taxa de bits por segundo(Padrão: 12.20k):$D "
read A_KBPS

if [ -z $A_KBPS ]; then
	A_KBPS='12.20k'
fi

echo -e "$BLUE===> Codecs$D\n"

FILE_TYPE=`echo $FO_NAME | sed -re 's/.*\.(.*)/\1/g'`

if [[ $FILE_TYPE == "3gp" || $FILE_TYPE == "3GP" ]]; then
	echo -e "$GREEN=> Codec de Video($D$RED h263$D$GREEN, mpeg4, h264 ):$D "
	read VCODEC
	echo -e "$GREEN=> Codec de Audio($D$RED amr_nb$D$GREEN, amr_wb, acc ):$D "
	read ACODEC
	
	## Defaults options
	AC=1
	AR=8000
	if [ -z $VCODEC ]; then
		VCODEC='h263'
	fi
	if [ -z $ACODEC ]; then
		ACODEC='amr_nb'
	fi
	
	if [[ $VCODEC == "h263" ]]; then
		echo -e "$YELLOW==> O Codec que você selecionou suporta as seguintes resoluções: $D"
		echo -e "$CYAN 128x96(sqcif)\t176x144(qcif)\t352x288(cif)\t704x576(4cif)\t1408x1152(16cif)$D"
		echo -e "$GREEN=> Você selecionou uma resolução diferente das citadas acima ?[s/N]:"
		read response
		if [[ $response == 's' || $response == 'S' ]]; then
			ask_vsize
		fi
	fi
else
	echo -e "$RED===> Tipo de Arquivo não suportado ainda, por favor faça a configuração manualmente$D"
	echo -e "$YELLOW==> Todas configurações passadas anteriormente, com exceção dos nomes dos arquivos, serão esquecidas!$D"
	echo -e "$GREEN=> Por favor entre com os parâmetros e valores a serem passados ao ffmpeg:$D"
	read CUSTON
	if [ -z $CUSTON ]; then
		echo -e "$RED==> Erro: você não passou nenhum parâmetro, saindo...$D"
		exit
	fi
fi

if [ -n $CUSTON ]; then
	echo "$YELLOW==> Iniciando Converção...$D"
	ffmpeg -i ${FI_NAME} -vcodec ${VCODEC} -s ${V_SIZE} -r ${FPS} -b:v ${V_KBPS} -acodec $ACODEC -b:a ${A_KBPS} -ac ${AC} -ar ${AR} ${FO_NAME}
	echo "O comando ficou:\n ffmpeg -i ${FI_NAME} -vcodec ${VCODEC} -s ${V_SIZE} -r ${FPS} -b:v ${V_KBPS} -acodec $ACODEC -b:a ${A_KBPS} -ac ${AC} -ar ${AR} ${FO_NAME}"
	if [ -s ${FO_NAME} ]; then
		echo -e "$GREEN==> Conversão concluída!!!$D"
	else
		echo -e "$RED==> ERRO na conversão olhe a saída mais acima para mais detalhes.$D"
	fi
else
	echo "$YELLOW==> Iniciando conversão configurada manualmente...$D"
	ffmpeg -i ${FI_NAME} ${CUSTON} ${FO_NAME}
	if [ -s ${FO_NAME} ]; then
		echo -e "$GREEN==> Conversão concluída!!!$D"
	else
		echo -e "$RED==> ERRO na conversão olhe a saída mais acima para mais detalhes.$D"
	fi
fi