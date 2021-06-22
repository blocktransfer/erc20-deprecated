// Copyright by USPTO & more abroad. See whitepaper.blocktransfer.io for latest IP.
// You cannot mimic our blockchain transfer agent protocol. Violators will be prosecuted.

// IT IS HEREBY SET FORTH BY BLOCKTRANS SYNDICATE THAT, GIVEN THE LIVELIHOOD OF THIS CONTRACT AND BOUNDS OF LAW,
// THIS IS THE OFFICIAL STOCK REGISTER FOR MGT CAPITAL INVESTMENTS INC. CLASS A 55302P202, EFFECTIVE 6-21-2021

// This is an example file and not indicative of any real-world asset.
// Asset-specific information plus addresses in contructor & function
// name and register information above to be changed for each firm.
pragma solidity ^0.8.1;

/**
 * @title Block Transfer
 * @dev A decentralized stock transfer agent protocol for global financial markets
 */
contract BlockTransfer_MGTCapitalInvestmentsInc_ClassAcommon_55302P202 {
    using SafeMath for uint256;
    constructor() {
        version = "A.31";
        peer_BT = msg.sender;
        onboardVerification = 0x1234567891234567891234567891234567891234;
        custody_DTCC = 0x00000000000000000000454157475;

        // Equity at launch initialization
        // Call getters for current values
        name = "MGT Capital Investments Inc. Class A 55302P202";
        symbol = "OTCQB: $MGTI";
        CUSIP = "55302P202";
        par = "0.001"; // USD
        authorizedShares = 2180000000000000000000000000;
        totalSupply = 536649910000000000000000000;
        restrictedShares = 7679116000000000000000000;
        unrestrictedShares = 528970794000000000000000000;
        assert(totalSupply = restrictedShares.add(unrestrictedShares));
        decimals = 18;
        isFrozen = true; // Unfrozen on effective morning
    }

    uint256 public authorizedShares;
    uint256 public totalSupply; // The number of outstanding shares
    uint256 public restrictedShares; // Represented in different contracts
    uint256 public unrestrictedShares;
    address public peer_BT;
    address public custody_DTCC;
    address public onboardVerification;
    bool public isFrozen;
    string public version;
    string public name;
    string public symbol;
    string public CUSIP;
    string public par;
    uint8 public decimals;
    uint8 public custodyInitializer;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ForwardSplit(uint256 indexed factor);
    event SharesIssued(uint256 indexed amount);
    event sharesAuthorized(uint256 indexed factor);
    event SharesCancelled(uint256 indexed amount);
    event ReverseSplit(uint256 indexed factor);
    event ForceRedact(address underInvestigation, address finalCustody, uint256 queryAmount);
    event NewSharesAllocated(uint256 indexed amount, address indexed recipient);
    event SharesAuthorized(uint256 indexed amount);
    event SymbolChanged(string indexed newTicker);
    event NameChanged(string indexed newName);
    event ChangedPeerBT(address indexed acquirer);
    event ChangedCustodyDTCC(address indexed acquirer);
    event InterimCustodyLocked();

    function balanceCede() public view returns (uint256) {
        return balances[custody_DTCC]; }
    function allowance(address owner, address spender) public view returns (uint256) {
      return allowed[owner][spender]; }
    function balanceOf(address account) public view returns (uint256) {
        return balances[account]; }

    // Use for all shareholder wallet interactions
    // IF INSIDER: File Form 4 after transaction
    function transfer(address to, uint256 value) public notFrozen returns (bool) {
        require(onboardVerification.validTransfer.value(msg.sender, to), 'Both accounts not in good standing');
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true; }

    // ADVANCED USE: Lets you allocate your assets to someone who can transfer them to any wallet from yours (use this for tender offers)
    function transferFrom(address from, address to, uint256 value) public notFrozen returns (bool) {
        require(onboardVerification.validTransfer.value(from, to), 'Both accounts not in good standing');
        require(value <= allowed[from][msg.sender], "You aren't approved for that much. Check your allowance");
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
        return true; }
    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true; }
    // Use increase/decrease to avoid someone taking your assets twice after you approve them (or revoke your tender offer acceptance)
    function decreaseAproval(address spender, uint256 minusValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][spender];
        if (minusValue >= oldValue) { // Protects from underflow when frontrun without SafeMath throwing
            allowed[msg.sender][spender] = 0;
        } else { allowed[msg.sender][spender] = oldValue.sub(minusValue); }
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true; }
    function increaseAproval(address spender, uint256 plusValue) public returns (bool) {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(plusValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true; }

    // Shareholder folioNums (internal at Block Transfer) mapped to the balances of
    // shareholders from the last transfer agent yet to claim their assets on-chain
    mapping(uint256 => uint256) public interimCustody;
    mapping(uint256 => uint8) public importStatus;
    function stateFolioNum(uint256 internalFolioNum) external view onlyPeerBT returns (uint8) {
        return importStatus[internalFolioNum]; }
    // 1 == successfully imported from last transfer agent; assets not claimed on-chain
    // 2 == assets claimed
    function setInterimCustody(uint256[] folioNums, uint256[] values) external onlyPeerBT returns (bool) {
        require(!custodyInitializer);
        for (uint256 i = 0; i < folioNums.length; i++) { // Watch gasLimit
            interimCustody[ folioNums[i] ] = values[i];
            importStatus[ folioNums[i] ] = 1; }
        return true; }
    function initializationComplete() external onlyPeerBT {
        require(!custodyInitializer);
        custodyInitializer = 64;
        emit InterimCustodyLocked(); }
    function claimAssets(uint256 folioNum, address shareholderWallet) external notFrozen onlyPeerBT returns (bool) {
        require(bytes(shareholderWallet) == 20);
        require(importStatus[folioNum] == 1, "Invalid shareholder status for this folio number");
        require(onboardVerification.addClaimedAssetholder.value(shareholderWallet));
        importStatus[folioNum] == 2;
        balances[shareholderWallet] = interimCustody[folioNum];
        interimCustody[folioNum] = 0;
        return true; }

    // Validate all regulatory submissions prior any cancellations, splits, or issuances
    function cancelShares(address[] eliminateAdresses) external onlyPeerBT returns (bool) {
        for(uint256 i = 0; i < eliminateAdresses.length; i++) { // Watch gasLimit
            totalSupply = totalSupply.sub(balances[ eliminateAdresses[i] ]);
            unrestrictedShares = unrestrictedShares.sub(balances[ eliminateAdresses[i] ]);
            balances[ eliminateAdresses[i] ] = 0; }
        return true; }
    // Repeat splits for restricted shares externally
    function forwardSplit(uint64 splitNumerator, uint64 splitDenominator, address[] addressBatch) external onlyPeerBT returns (bool) {
        uint256 mulBalance;
        uint256 difference;
        uint256 splitRatio = (splitNumerator.mul(10**decimals)).div(splitDenominator);
        for(uint256 i = 0; i < addressBatch.length; i++) { // Watch gasLimit
            mulBalance = (balances[ addressBatch[i] ].mul(splitRatio)).div(10**decimals);
            difference = mulBalance.sub(balances[ addressBatch[i] ]);
            totalSupply = totalSupply.add(difference);
            unrestrictedShares = unrestrictedShares.add(difference);
            balances[ addressBatch[i] ] = mulBalance; }
        return true; }
    function reverseSplit(uint64 splitNumerator, uint64 splitDenominator, address[] addressBatch) external onlyPeerBT returns (bool) {
        uint256 divBalance;
        uint256 difference;
        uint256 splitRatio = (splitNumerator.mul(10**decimals)).div(splitDenominator);
        for(uint256 i = 0; i < addressBatch.length; i++) { // Watch gasLimit
            divBalance = (balances[ addressBatch[i] ].div(splitRatio)).div(10**decimals);
            difference = balances[ addressBatch[i] ].sub(divBalance);
            totalSupply = totalSupply.sub(difference);
            unrestrictedShares = unrestrictedShares.sub(difference);
            balances[ addressBatch[i] ] = divBalance; }
        return true; }
    function allocateNewShares(uint256 amount, address recipient) external onlyPeerBT {
        require(authorizedShares >= amount.add(totalSupply));
        totalSupply.add(amount);
        unrestrictedShares.add(amount);
        balances[recipient].add(amount);
        emit NewSharesAllocated(amount, recipient); }
    function authorizeNewShares(uint256 amount) external onlyPeerBT {
        authorizedShares.add(amount);
        emit SharesAuthorized(amount); }
    function restrictedSharesRedemption(address designatedRedemptionPool, address insider, uint256 amount) external notFrozen onlyPeerBT returns (bool) {
        restrictedShares = restrictedShares.sub(amount);
        unrestrictedShares = unrestrictedShares.add(amount);
        balances[designatedRedemptionPool] = balances[designatedRedemptionPool].sub(amount);
        balances[insider] = balances[insider].add(amount);
        return true; }

    // Used for complex remediation from onboardVerification. Ought be rare
    function forceRedact(address underInvestigation, address finalCustody, uint256 queryAmount) external notFrozen onlyPeerBT returns (bool) {
        balances[underInvestigation] = balances[underInvestigation].sub(queryAmount);
        balances[finalCustody] = balances[finalCustody].add(queryAmount);
        emit ForceRedact(underInvestigation, finalCustody, queryAmount);
        return true; }

    // Used when home exchange, ticker, or name changes
    function updateTicker(string newTicker) external onlyPeerBT {
        symbol = newTicker;
        emit SymbolChanged(newTicker); }
    function updateName(string newName) external onlyPeerBT {
        name = newName;
        emit NameChanged(newName); }

    function freeze() external onlyPeerBT {
        isFrozen = true; }
    function unfreeze() external onlyPeerBT {
        isFrozen = false; }
    modifier notFrozen {
        require(!isFrozen, "The contract is frozen, likely for some regulatory bookkeeping export. We apologize for the inconvenience. Please try again in 15 minutes. If challenge persists, see updates.blocktransfer.io, as there may be a major update for this asset");
        _; }
    modifier onlyPeerBT {
        require(msg.sender == peer_BT, "Only Peer BT can call this function");
        _; }
    // Security
    function newPeerBT(address acquirer) external onlyPeerBT {
        peer_BT = acquirer;
        emit ChangedPeerBT(acquirer); }
    function newCustodyDTCC(address acquirer) external onlyPeerBT {
        balances[acquirer] = balances[custody_DTCC];
        custody_DTCC = acquirer;
        emit ChangedCustodyDTCC(acquirer); }
    // For if the issuer is acquired, merges, goes private, or any other action invalidating this asset
    function endTransfer() external onlyPeerBT {
        selfdestruct(payable(msg.sender)); }
    fallback() external payable {} //[payable] implimentation tbd for contract receiving tokens

    // These public getters exist by default & are removable
    // Replicated to emphasize fields for regulatory comliance
    function name() public view returns (string memory) {
        return name; }
    function symbol() public view returns (string memory) {
        return symbol; }
    function par() public view returns (string memory) {
        return par; }
    function decimals() public view returns (uint8) {
        return decimals; }
    function authorizedShares() public view returns (uint256) {
        return authorizedShares; }
    function totalSupply() public view returns (uint256) {
        return totalSupply; }
    function restrictedShares() public view returns (uint256) {
        return restrictedShares; }
    function unrestrictedShares() public view returns (uint256) {
        return unrestrictedShares; }
    function isFrozen() public view returns (bool) {
        return isFrozen; }
    function peer_BT() public view returns (address) {
        return peer_BT; }
    function custody_DTCC() public view returns (address) {
        return custody_DTCC; }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b); // Short-circuit evaluates
        return c; }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b; }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b; }
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
        return c; }
}
// INTERACTING WITH THIS CONTRACT BINDINGLY EQUATES TO IRREVOCABLE TOTAL CONSENT TO BLOCKTRANS SYNDICATE'S TERMS OF SERVICE & PRIVACY AGREEMENTS
