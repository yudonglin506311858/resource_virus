
conda activate rnaseq
cd /data1/yudonglin/HIV_project/ATAC/bowtie2/CPM_sambamba/data
for bw in *.bw; do
    base=$(basename "$bw" .bw)
    echo "Processing $bw ..."

    # 1. bigWig → bedGraph
    bigWigToBedGraph "$bw" temp.bedGraph

    # 2. 修改 HIV 坐标 (+50000)
    awk '{if($1=="HIV"){s=$2+50000; e=$3+50000; if(s<0) s=0; print $1, s, e, $4} else {print $0}}' OFS="\t" temp.bedGraph > shifted.unsorted.bedGraph

    # 3. 排序
   LC_COLLATE=C  sort -k1,1 -k2,2n -S 4G --parallel=8 shifted.unsorted.bedGraph > shifted.bedGraph

    # 4. 转回 bigWig
    bedGraphToBigWig shifted.bedGraph /data/yudonglin/reference/virus/HIV_hg38/chrom.sizes "${base}_shifted.bw"

    echo "Done → ${base}_shifted.bw"
done
