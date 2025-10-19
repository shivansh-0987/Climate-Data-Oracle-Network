 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/// @title Climate Data Oracle Network
contract ClimateDataOracle {
    struct DataPoint {
        uint256 timestamp;
        string dataType;
        int256 value;
        string location::
        address provider;
        bool verified;
    }

    address public owner;

    mapping(bytes32 => DataPoint) public climateData;
    bytes32[] public dataIds;
    mapping(address => bool) public authorizedProviders;
    mapping(bytes32 => bool) private dataIdExists;

    event DataSubmitted(bytes32 indexed dataId, string dataType, int256 value, string location);
    event DataVerified(bytes32 indexed dataId, bool verified);
    event ProviderAuthorized(address indexed provider, bool status);
    event DataRevoked(bytes32 indexed dataId);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyAuthorizedProvider() {
        require(authorizedProviders[msg.sender], "Provider not authorized");
        _;
    }

    // Authorize or revoke providers
    function setProviderAuthorization(address provider, bool status) external onlyOwner {
        authorizedProviders[provider] = status;
        emit ProviderAuthorized(provider, status);
    }

    // Submit new climate data
    function submitData(string memory dataType, int256 value, string memory location) external onlyAuthorizedProvider returns (bytes32) {
        bytes32 dataId = keccak256(abi.encodePacked(block.timestamp, msg.sender, dataType, location, value));
        require(!dataIdExists[dataId], "Duplicate data");

        climateData[dataId] = DataPoint({
            timestamp: block.timestamp,
            dataType: dataType,
            value: value,
            location: location,
            provider: msg.sender,
            verified: false
        });

        dataIds.push(dataId);
        dataIdExists[dataId] = true;

        emit DataSubmitted(dataId, dataType, value, location);
        return dataId;
    }

    // Verify submitted data
    function verifyData(bytes32 dataId, bool verified) public onlyOwner {
        require(climateData[dataId].timestamp > 0, "Data doesn't exist");
        climateData[dataId].verified = verified;
        emit DataVerified(dataId, verified);
    }

    // Retrieve a specific data point
    function getDataPoint(bytes32 dataId) public view returns (
        uint256 timestamp,
        string memory dataType,
        int256 value,
        string memory location,
        address provider,
        bool verified
    ) {
        DataPoint memory data = climateData[dataId];
        require(data.timestamp > 0, "Data doesn't exist");

        return (
            data.timestamp,
            data.dataType,
            data.value,
            data.location,
            data.provider,
            data.verified
        );
    }

    // Total submitted data points
    function getDataCount() public view returns (uint256) {
        return dataIds.length;
    }

    // ? NEW FUNCTION 1: Return all data IDs
    function getAllDataIds() public view returns (bytes32[] memory) {
        return dataIds;
    }

    // ? NEW FUNCTION 2: Count verified data points
    function getVerifiedDataCount() public view returns (uint256 count) {
        for (uint i = 0; i < dataIds.length; i++) {
            if (climateData[dataIds[i]].verified) {
                count++;
            }
        }
    }

    // ? NEW FUNCTION 3: Get data by index
    function getDataByIndex(uint index) public view returns (
        bytes32 dataId,
        string memory dataType,
        int256 value,
        string memory location,
        bool verified
    ) {
        require(index < dataIds.length, "Index out of bounds");
        dataId = dataIds[index];
        DataPoint storage d = climateData[dataId];
        return (dataId, d.dataType, d.value, d.location, d.verified);
    }

    // ? NEW FUNCTION 4: Revoke data by ID (owner only)
    function revokeData(bytes32 dataId) public onlyOwner {
        require(climateData[dataId].timestamp > 0, "Data doesn't exist");

        delete climateData[dataId];
        dataIdExists[dataId] = false;

        for (uint i = 0; i < dataIds.length; i++) {
            if (dataIds[i] == dataId) {
                dataIds[i] = dataIds[dataIds.length - 1];
                dataIds.pop();
                break;
            }
        }

        emit DataRevoked(dataId);
    }

    // ? NEW FUNCTION 5: Check if data ID exists
    function isDataIdExist(bytes32 dataId) public view returns (bool) {
        return dataIdExists[dataId];
    }
}

// START
Updated on 2025-10-19
// END
