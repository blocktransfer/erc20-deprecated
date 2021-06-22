// Copyright by USPTO & more abroad. See whitepaper.blocktransfer.io for latest IP.
// You cannot mimic our blockchain transfer agent protocol. Violators will be prosecuted.

// IT IS HEREBY SET FORTH BY BLOCKTRANS SYNDICATE THAT, GIVEN THE LIVELIHOOD OF THIS CONTRACT AND BOUNDS OF LAW,
// THIS IS THE OFFICIAL PUBLIC RECORD OF ETHEREUM ADDRESSES BACKED BY COMPLIANT IDENTITY FOR ALL SERVICED ISSUERS

// This is an example file and not indicative of any real-world identification claims.
pragma solidity ^0.8.1;

contract BlockTransfer_MasterVerification {
    constructor() {
        peer_BT = msg.sender;
    }
    address public peer_BT;
    address public complianceAdmin;
    address public onboardingAdmin;
    address public supportAdmin;
    address public resolutionsAdmin;
    address public executiveAdmin;
    event ChangedPeerBT(address indexed acquirer);
    event ChangedComplianceAdmin(address indexed acquirer);
    event ChangedOnboardingAdmin(address indexed acquirer);
    event ChangedSupportAdmin(address indexed acquirer);
    event ChangedResolutionsAdmin(address indexed acquirer);
    event ChangedExecutiveAdmin(address indexed acquirer);
    event Onboarded(address indexed holder);
    event ClosedKeysCase(address victim, address newShareholderWallet);
    mapping(address => mapping(string => bool)) private authorizations;
    mapping (address => uint8) public onboarded;
    // 8 = AML investigation ongoing
    // 9 = admin blacklisted, AML violation
    // 12 = SEC restriction/government investigation
    // 13 = government documentation bounced as false
    // 25 = investigating loss of keys reported by shareholder
    // 26 = suspected thief in key-loss case by chain analysis
    // 27 = unknowing buyer from accused thief before reported
    // 64 = Account in good standing
    function statusBT(address account) public view returns (uint8) {
        return onboarded[account]; }

    function validTransfer(address from, address to) public view returns (bool) {
        return (onboarded[from]==64 && 64==onboarded[to]);
    }

    function addOneOnboard(address holder) external hasRole('onboarding') {
        onboarded[holder] = 64;
        emit Onboarded(holder); }
    function addClaimedAssetholder(address holder) external onlyPeerBT returns (bool) {
        onboarded[holder] = 64;
        emit Onboarded(holder);
        return true; }
    function addManyOnboard(address[] holders) external hasRole('onboarding') returns (bool) {
        for (uint256 i = 0; i < holders.length; i++) { // Watch gasLimit
            onboarded[ holders[i] ] = 64;
            emit Onboarded( holders[i] ); }
        return true; }

    function investigateAML(address violator) external hasRole('compliance') returns (bool) {
        onboarded[violator] = 8;
        return true; }
    function violatedAML(address violator) external hasRole('compliance') returns (bool) {
        onboarded[violator] = 9;
        return true; }
    function stopSEC(address violator) external hasRole('compliance') returns (bool) {
        onboarded[violator] = 12;
        return true; }
    function fakeID(address violator) external hasRole('compliance') returns (bool) {
        onboarded[violator] = 13;
        return true; }
    function investigateKeysLost(address victim) external hasRole('support') returns (bool) {
        onboarded[victim] = 25;
        return true; }
    function suspectAdversary(address accused) external hasRole('resolutions') returns (bool) {
        onboarded[accused] = 26;
        return true; }
    function unknowingKeyLossBuyer(address involved) external hasRole('resolutions') returns (bool) {
        onboarded[involved] = 27;
        return true; }
    function reinstate(address innocent) external hasRole('resolutions') returns (bool) {
        onboarded[innocent] = 64;
        return true; }

    // If you lose your private keys, we may require a (generally free) medallion-stamp certificate submitted through your local financial institution (or ~$150 online),
    // & we may require surety bond insurance (~3% market value; additionally may require an affidavit of loss) to cover the underwriter risk we take (case dependent)
    // Please be patient. We have to forcibly transfer all your old assets to your new address for each security you own at Block Transfer. Keep your keys safe!
    function keysCaseAcceptance(address victim, address newShareholderWallet) external hasRole('executive') returns (bool) {
        require(onboarded[victim] == 25);
        onboarded[victim] = 0;
        onboarded[newShareholderWallet] = 64;
        emit ClosedKeysCase(victim, newShareholderWallet);
        return true; }

    function assignRole(address teammate, string role) external {
        if(msg.sender == complianceAdmin && role == 'compliance') {
            authorizations[teammate]['compliance'] = true;
        }
        else if(msg.sender == onboardingAdmin && role == 'onboarding') {
            authorizations[teammate]['onboarding'] = true;
        }
        else if(msg.sender == supportAdmin && role == 'support') {
            authorizations[teammate]['support'] = true;
        }
        else if(msg.sender == resolutionsAdmin && role == 'resolutions') {
            authorizations[teammate]['resolutions'] = true;
        }
        else if(msg.sender == executiveAdmin && role == 'executive') {
            authorizations[teammate]['executive'] = true;
        }
    }
    function revokeRole(address teammate, string role) external {
        if(msg.sender == complianceAdmin && role == 'compliance') {
            authorizations[teammate]['compliance'] = false;
        }
        else if(msg.sender == onboardingAdmin && role == 'onboarding') {
            authorizations[teammate]['onboarding'] = false;
        }
        else if(msg.sender == supportAdmin && role == 'support') {
            authorizations[teammate]['support'] = false;
        }
        else if(msg.sender == resolutionsAdmin && role == 'resolutions') {
            authorizations[teammate]['resolutions'] = false;
        }
        else if(msg.sender == executiveAdmin && role == 'executive') {
            authorizations[teammate]['executive'] = false;
        }
    }
    function isAuthorized(address teammate, string role) public returns (bool) {
        return authorizations[teammate][role]; }

    modifier hasRole(string role) {
        require(authorizations[msg.sender][role], "Teammate not authorized for required role");
        _; }
    modifier onlyPeerBT {
        require(msg.sender == peer_BT, "Only Peer BT can call this function");
        _; }
    // Security
    function newPeerBT(address acquirer) external onlyPeerBT {
        peer_BT = acquirer;
        emit ChangedPeerBT(acquirer); }
    function newCompliance(address acquirer) external onlyPeerBT {
        complianceAdmin = acquirer;
        emit ChangedComplianceAdmin(acquirer); }
    function newOnboarding(address acquirer) external onlyPeerBT {
        onboardingAdmin = acquirer;
        emit ChangedOnboardingAdmin(acquirer); }
    function newSupport(address acquirer) external onlyPeerBT {
        supportAdmin = acquirer;
        emit ChangedSupportAdmin(acquirer); }
    function newResolutions(address acquirer) external onlyPeerBT {
        resolutionsAdmin = acquirer;
        emit ChangedResolutionsAdmin(acquirer); }
    function newExecutive(address acquirer) external onlyPeerBT {
        executiveAdmin = acquirer;
        emit ChangedExecutiveAdmin(acquirer); }
    fallback () external payable {} //xxx
}
// INTERACTING WITH THIS CONTRACT BINDINGLY EQUATES TO IRREVOCABLE TOTAL CONSENT TO BLOCKTRANS SYNDICATE'S TERMS OF SERVICE & PRIVACY AGREEMENTS
