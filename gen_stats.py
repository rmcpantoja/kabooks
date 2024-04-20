import collections
import tqdm
from os.path import join

# Monkey patch:
def get_transcripts(transcripts_text):
    transcripts_dict = {}
    for line in transcripts_text:
        filename, wav2bec_text, book_text, similarity = line.split('|')
        transcripts_dict[filename] = similarity
    # Sorting dict by key (filename)
    ordered_transcripts_dict = collections.OrderedDict(sorted(transcripts_dict.items()))
    return ordered_transcripts_dict

def generate_stats(base_dir, result_file, output_stats_file, min_similarity = 0.75):
	transcript = join(base_dir, result_file)
	stats = join(base_dir, output_stats_file)
	with open(transcript, encoding='utf-8') as f:
		metadata = f.readlines()
	transcripts = get_transcripts(metadata)
	good_files = []
	bad_files = []
	priority_files = []
	total_similarity = 0
	for filename, similarity in tqdm.tqdm(transcripts.items()):
		similarity = float(similarity)
		total_similarity += similarity
		if similarity == 0.0:
			priority_files.append((filename, similarity))
		elif similarity >= min_similarity:
			good_files.append((filename, similarity))
		else:
			bad_files.append((filename, similarity))
	avg_similarity = total_similarity / len(transcripts)
	print(f"{len(transcripts)} total files.")
	print(f"{len(good_files)} good files.")
	print(f"{len(bad_files)} bad files.")
	print(f"and {len(priority_files)} priority files to review.")
	with open(stats, "w") as f:
		f.write("Good files:\n")
		for file, similarity in good_files:
			f.write(f"{file}|{similarity}\n")
		f.write("\nBad files:\n")
		for file, similarity in bad_files:
			f.write(f"{file}|{similarity}\n")
		f.write("\nFiles that you need to review:\n")
		for file, similarity in priority_files:
			f.write(f"{file}|{similarity}\n")
		f.write(f"Total similarity: {total_similarity}\nAvg similarity: {avg_similarity}")


generate_stats("C:/Users/LENOVO_User/kabooks", "resultado.txt", "stats.txt")