qiime rescript get-ncbi-data --p-query '33175[BioProject] OR 33317[BioProject]' --m-accession-ids-file homd/accession-list.txt --o-sequences ncbi-refseqs-unfiltered.qza --o-taxonomy ncbi-refseqs-taxonomy-unfiltered.qza

qiime rescript filter-seqs-length-by-taxon --i-sequences ncbi-refseqs-unfiltered.qza --i-taxonomy ncbi-refseqs-taxonomy-unfiltered.qza --p-labels Archaea Bacteria --p-min-lens 900 1200 --p-max-lens 1800 2400 --o-filtered-seqs ncbi-refseqs.qza --o-discarded-seqs ncbi-refseqs-tooshortorlong.qza

qiime rescript filter-taxa --i-taxonomy ncbi-refseqs-taxonomy-unfiltered.qza --m-ids-to-keep-file ncbi-refseqs.qza --o-filtered-taxonomy ncbi-refseqs-taxonomy.qza

qiime rescript dereplicate --i-sequences ncbi-refseqs.qza --i-taxa ncbi-refseqs-taxonomy.qza --p-mode 'uniq' --p-rank-handles 'greengenes' --o-dereplicated-sequences ncbi-refseqs-derep-uniq.qza --o-dereplicated-taxa ncbi-refseqs-tax-derep-uniq.qza

qiime feature-classifier extract-reads --i-sequences ncbi-refseqs-derep-uniq.qza --p-f-primer CCTACGGGNGGCWGCAG --p-r-primer GACTACHVGGGTATCTAATCC --p-n-jobs 20 --p-read-orientation 'forward' --o-reads ncbi-refseqs-v34.qza

qiime rescript dereplicate --i-sequences ncbi-refseqs-v34.qza --i-taxa ncbi-refseqs-tax-derep-uniq.qza --p-rank-handles 'greengenes' --p-mode 'uniq' --o-dereplicated-sequences ncbi-refseqs-v34-uniq.qza --o-dereplicated-taxa ncbi-refseqs-tax-v34-uniq.qza

qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads ncbi-refseqs-v34-uniq.qza --i-reference-taxonomy ncbi-refseqs-tax-v34-uniq.qza --o-classifier ncbi-v34-classifier.qza

biom convert -i feature-table2.tsv -o feature-table2.biom --to-hdf5 --table-type="OTU table"

qiime tools import --type 'FeatureTable[Frequency]' --input-path feature-table2.biom --output-path ../../rescript/feature-table.qza

qiime clawback sequence-variants-from-samples --i-samples feature-table.qza --o-sequences sv.qza

qiime feature-classifier classify-sklearn --i-classifier ncbi-v34-classifier.qza --i-reads sv.qza --p-confidence=disable --o-classification classification.qza

qiime clawback generate-class-weights --i-reference-taxonomy ncbi-refseqs-tax-v34-uniq.qza --i-reference-sequences ncbi-refseqs-v34-uniq.qza --i-samples feature-table.qza --i-taxonomy-classification classification.qza --o-class-weight oral-weights.qza --verbose

qiime phylogeny align-to-tree-mafft-raxml --i-sequences refseq.qza --p-n-threads 20 --output-dir phylogeny --verbose

#qiime rescript evaluate-fit-classifier --i-sequences ncbi-refseqs.qza --i-taxonomy ncbi-refseqs-taxonomy.qza --o-classifier ncbi-refseqs-classifier.qza --o-evaluation ncbi-classifier-evaluation.qzv --o-observed-taxonomy ncbi-refseqs-predicted-taxonomy.qza
