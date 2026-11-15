# Evidence and detection limits

## Provenance and credit

The French report is coauthored by Mohammed Laasri and Salaheddine Haidarah for ISMAGI, academic year 2025–2026. Mohammed carried out most of the practical work. The original VMs and working files were lost after a laptop format.

The local rules, network examples, and sample alerts correspond to the report's annexes. Shell helpers are reconstructed reference scripts with corrections made during portfolio preparation. The report is preserved unchanged; the scripts are not claimed as recovered originals.

## What the signatures mean

- **SSH, SID 1000002:** counts matching `SSH-` banners to port 22 per source over ten seconds. Encrypted SSH authentication failures are not visible to this payload rule. A burst of connections can have benign causes, and several password attempts within one connection can be missed.
- **HTTP, SID 1000003:** looks for literal `../` and `/etc/passwd` strings. It does not handle every encoded or normalized traversal form, and a match does not establish successful file disclosure. The supplied log shows community SID 1122 for the web request, not this local SID.
- **SMB, SID 1000005:** matches established client TCP traffic to port 445 without checking an SMB enumeration operation. Normal SMB traffic can trigger it. It is a deliberately broad learning example.
- **XMAS, SID 1000006:** checks the specified TCP flag combination. The supplied alert excerpt does not contain this SID, so the repository does not claim a demonstrated alert for this scenario.
- **FTP, SID 1000007:** detects the plaintext command `USER anonymous`. The rule is not applicable to an encrypted FTPS session and does not show that authentication succeeded.

Messages such as “SSH Brute Force Attempt” retain their wording from the report. Interpret them using these limits, rather than treating the label as proof.

## Results available

The sample log transcribes the report's Annex D, with whitespace normalized for readability. It contains SSH, SMB, FTP, and community-rule alerts. No original PCAP, complete raw alert archive, benign traffic dataset, measured false-positive rate, throughput benchmark, or new replay result is available.

## Scope

The demonstrated architecture is passive detection. Prevention, SIEM dashboards, and anomaly/ML detection appear as future work in the report and are not implemented here. Turning on promiscuous mode does not establish complete capture coverage or an undetectable sensor.
