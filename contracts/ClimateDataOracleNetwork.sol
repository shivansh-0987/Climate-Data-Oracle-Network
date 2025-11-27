// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title ClimateDataOracleNetwork
 * @notice A decentralized oracle network for submitting and verifying climate data.
 */
contract ClimateDataOracleNetwork {

    address public admin;
    uint256 public oracleCount;
    uint256 public dataCount;

    struct Oracle {
        uint256 id;
        address owner;
        string name;
        bool active;
    }

    struct ClimateData {
        uint256 id;
        uint256 oracleId;
        string dataHash;    // IPFS hash or encoded climate data
        uint256 timestamp;
        bool verified;
    }

    mapping(uint256 => Oracle) public oracles;
    mapping(uint256 => ClimateData) public climateData;
    mapping(address => uint256[]) public userOracles;
    mapping(uint256 => uint256[]) public oracleData;

    event OracleRegistered(uint256 indexed id, address indexed owner, string name);
    event OracleActivated(uint256 indexed id);
    event OracleDeactivated(uint256 indexed id);
    event DataSubmitted(uint256 indexed id, uint256 indexed oracleId, string dataHash);
    event DataVerified(uint256 indexed id);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "ClimateDataOracleNetwork: NOT_ADMIN");
        _;
    }

    modifier oracleExists(uint256 id) {
        require(id > 0 && id <= oracleCount, "ClimateDataOracleNetwork: ORACLE_NOT_FOUND");
        _;
    }

    modifier dataExists(uint256 id) {
        require(id > 0 && id <= dataCount, "ClimateDataOracleNetwork: DATA_NOT_FOUND");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /// @notice Register a new oracle
    function registerOracle(string calldata name) external returns (uint256) {
        require(bytes(name).length > 0, "ClimateDataOracleNetwork: EMPTY_NAME");

        oracleCount++;
        oracles[oracleCount] = Oracle({
            id: oracleCount,
            owner: msg.sender,
            name: name,
            active: true
        });

        userOracles[msg.sender].push(oracleCount);

        emit OracleRegistered(oracleCount, msg.sender, name);
        return oracleCount;
    }

    /// @notice Activate an oracle
    function activateOracle(uint256 id) external oracleExists(id) {
        Oracle storage o = oracles[id];
        require(msg.sender == o.owner || msg.sender == admin, "ClimateDataOracleNetwork: UNAUTHORIZED");
        o.active = true;
        emit OracleActivated(id);
    }

    /// @notice Deactivate an oracle
    function deactivateOracle(uint256 id) external oracleExists(id) {
        Oracle storage o = oracles[id];
        require(msg.sender == o.owner || msg.sender == admin, "ClimateDataOracleNetwork: UNAUTHORIZED");
        o.active = false;
        emit OracleDeactivated(id);
    }

    /// @notice Submit climate data
    function submitData(uint256 oracleId, string calldata dataHash) external oracleExists(oracleId) returns (uint256) {
        Oracle storage o = oracles[oracleId];
        require(o.active, "ClimateDataOracleNetwork: INACTIVE_ORACLE");

        dataCount++;
        climateData[dataCount] = ClimateData({
            id: dataCount,
            oracleId: oracleId,
            dataHash: dataHash,
            timestamp: block.timestamp,
            verified: false
        });

        oracleData[oracleId].push(dataCount);

        emit DataSubmitted(dataCount, oracleId, dataHash);
        return dataCount;
    }

    /// @notice Verify submitted data (admin-only)
    function verifyData(uint256 dataId) external onlyAdmin dataExists(dataId) {
        ClimateData storage d = climateData[dataId];
        require(!d.verified, "ClimateDataOracleNetwork: ALREADY_VERIFIED");
        d.verified = true;
        emit DataVerified(dataId);
    }

    /// @notice Get oracle info
    function getOracle(uint256 id) external view oracleExists(id) returns (Oracle memory) {
        return oracles[id];
    }

    /// @notice Get climate data info
    function getData(uint256 id) external view dataExists(id) returns (ClimateData memory) {
        return climateData[id];
    }

    /// @notice Get all oracles owned by a user
    function getUserOracles(address user) external view returns (uint256[] memory) {
        return userOracles[user];
    }

    /// @notice Get all data submitted by an oracle
    function getOracleData(uint256 oracleId) external view oracleExists(oracleId) returns (uint256[] memory) {
        return oracleData[oracleId];
    }

    /// @notice Change admin
    function changeAdmin(address newAdmin) external onlyAdmin {
        require(newAdmin != address(0), "ClimateDataOracleNetwork: ZERO_ADMIN");
        emit AdminChanged(admin, newAdmin);
        admin = newAdmin;
    }
}
