# dss-snog

Oracle whitelisting for permissioned users.

## Requirements

* Foundry

## Usage

DssSnog enables Maker governance the ability to add users capable of adding whitelisted readers to Kissable oracle contracts.

This allows governance the ability to delegate whitelist access to a blessed account, permitting them to add readers to the oracle contracts quickly while bypassing the governance cycle.

### Assumptions

* `wards`: A top-level authorization source. (i.e. Token Governance). Can add new `snoggers` and call `kiss`. Wards can add or remove snoggers.

* `snoggers`: A permissioned user, capable of calling `kiss` on any oracle that `DssSnog` is a ward of. `snoggers` may add readers, but they may not remove them. Snoggers may remove their own role, but cannot add new ones.
