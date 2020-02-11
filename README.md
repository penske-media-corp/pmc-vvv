# PMC-VVV
To build a new PMC-VVV environment simply run `sh <(curl -s https://raw.githubusercontent.com/penske-media-corp/pmc-vvv/master/build-me-vvv.sh)` in your terminal and follow the prompts. If you have any issues please refer to the VVV documentation or `#engineering` for questions. Engineering owns the evolution of this project and ops offers ultimate support of tooling. If you feel the urge to change something or find a bug the please submit a PR yourself.

# Build PMC-VVV
- `sh <(curl -s https://raw.githubusercontent.com/penske-media-corp/pmc-vvv/master/build-me-vvv.sh)`
  - If running for the first time:
    - Answer `1` to all prompts
  - If re-running the script:
    - You can skip the first two steps ( cloning VVV and copying the config )
    - Run from inside VVV directory
- When prompted for a password on git repositories enter an application password to clone repositories
- If at any time PMC-VVV fails to build or a site doesn't provision you can re-run/skip any of the steps in the go script

