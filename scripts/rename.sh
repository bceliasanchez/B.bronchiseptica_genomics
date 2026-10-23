#rename iqtree output from accessions to IDs
#!/usr/bin/env python3
"""
Replace tip labels in a Newick tree file produced by IQ-TREE using a mapping file.

Usage:
    python3 replace_iqtree_labels.py table.txt input.treefile output.treefile

Assumptions:
- table.txt is tab-delimited, ID is in column 1, accession is in column 7 (1-based).
- Tip labels may be unquoted or quoted with " or '.
- Common suffixes "_snippy" or " snippy" are handled.
"""
import sys
import re

if len(sys.argv) != 4:
    print("Usage: python3 replace_iqtree_labels.py table.txt input.treefile output.treefile", file=sys.stderr)
    sys.exit(1)

map_path, tree_in, tree_out = sys.argv[1], sys.argv[2], sys.argv[3]

# Build accession -> ID map
acc_to_id = {}
duplicates = {}
with open(map_path, 'r', encoding='utf-8') as mf:
    for lineno, line in enumerate(mf, 1):
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue
        cols = line.split("\t")
        if len(cols) < 7:
            # skip lines without enough columns
            continue
        id_val = cols[0].strip()
        accession = cols[6].strip()
        if accession == "":
            continue
        if accession in acc_to_id and acc_to_id[accession] != id_val:
            duplicates.setdefault(accession, []).append((acc_to_id[accession], id_val, lineno))
        acc_to_id[accession] = id_val

if duplicates:
    print("Warning: duplicate accessions mapped to multiple IDs (using last occurrence):", file=sys.stderr)
    for acc, infos in duplicates.items():
        print(f"  {acc}: {infos}", file=sys.stderr)

# Read tree text
with open(tree_in, 'r', encoding='utf-8') as tf:
    tree_text = tf.read()

# Helper to perform replacement for a single label token (may be quoted)
def map_label(label):
    # preserve quotes
    if (label.startswith('"') and label.endswith('"')) or (label.startswith("'") and label.endswith("'")):
        q = label[0]
        core = label[1:-1]
    else:
        q = ""
        core = label

    # try exact match
    if core in acc_to_id:
        new = acc_to_id[core]
        return q + new + q

    # try _snippy and " snippy" suffixes
    if core.endswith("_snippy"):
        base = core[:-7]
    elif core.endswith(" snippy"):
        base = core[:-7]
    else:
        base = None

    if base and base in acc_to_id:
        return q + acc_to_id[base] + q

    # no mapping found: return original
    return label

# Regex to match tip labels in Newick:
# - labels appear after ( or , or at start, and before : or , or ) or [ (for metadata)
# - match quoted labels ("..."/'...') or unquoted tokens with common characters
label_pattern = re.compile(
    r'(?<=[:\(,])\s*'                            # preceded by : or ( or ,
    r'("(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'|[A-Za-z0-9_.\-\s]+?)'  # quoted or unquoted label (non-greedy)
    r'(?=\s*(?:[:,\)\[\;]))'                     # followed by : , ) [ or ;
)

# Apply replacement
new_tree = label_pattern.sub(lambda m: map_label(m.group(1)), tree_text)

# Write output
with open(tree_out, 'w', encoding='utf-8') as out:
    out.write(new_tree)

print(f"Wrote relabelled tree to: {tree_out}")


