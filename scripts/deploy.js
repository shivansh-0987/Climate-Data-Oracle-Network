// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Climate Data Oracle Network
 * @dev Smart contract for managing climate data oracles
 */
contract Project {
    address public owner;
    
    // Oracle data structure
    struct DataPoint {
        uint256 timestamp;
        string dataType;
        int256 value;
        string location;
        address provider;
        bool verified;
    }
    
    // Mapping from data ID to DataPoint
    mapping(bytes32 => DataPoint) public climateData;
    
    // Array to store all data IDs
    bytes32[] public dataIds;
    
    // Mapping for authorized data providers
    mapping(address => bool) public authorizedProviders;
    
    // Events
    event DataSubmitted(bytes32 indexed dataId, string dataType, int256 value, string location);
    event DataVerified(bytes32 indexed dataId, bool verified);
    event ProviderAuthorized(address indexed provider, bool status);
    
    /**
     * @dev Constructor sets the owner to the contract deployer
     */
    constructor() {
        owner = msg.sender;
    }
    
    /**
     * @dev Modifier to check if the caller is the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    /**
     * @dev Modifier to check if the caller is an authorized provider
     */
    modifier onlyAuthorizedProvider() {
        require(authorizedProviders[msg.sender], "Provider not authorized");
        _;
    }
    
    /**
     * @dev Authorizes or deauthorizes a data provider
     * @param provider Address of the provider
     * @param status Authorization status
     */
    function setProviderAuthorization(address provider, bool status) public onlyOwner {
        authorizedProviders[provider] = status;
        emit ProviderAuthorized(provider, status);
    }
    
    /**
     * @dev Submits climate data to the oracle network
     * @param dataType Type of climate data (e.g., "temperature", "humidity")
     * @param value The climate data value (scaled to handle decimals)
     * @param location The geographical location of the data point
     * @return dataId The unique identifier for the submitted data
     */
    function submitData(
        string memory dataType,
        int256 value,
        string memory location
    ) public onlyAuthorizedProvider returns (bytes32) {
        bytes32 dataId = keccak256(abi.encodePacked(
            dataType,
            value,
            location,
            msg.sender,
            block.timestamp
        ));
        
        climateData[dataId] = DataPoint({
            timestamp: block.timestamp,
            dataType: dataType,
            value: value,
            location: location,
            provider: msg.sender,
            verified: false
        });
        
        dataIds.push(dataId);
        
        emit DataSubmitted(dataId, dataType, value, location);
        
        return dataId;
    }
    
    /**
     * @dev Verifies climate data (can only be called by the owner)
     * @param dataId Unique identifier of the data to verify
     * @param verified Verification status
     */
    function verifyData(bytes32 dataId, bool verified) public onlyOwner {
        require(climateData[dataId].timestamp > 0, "Data doesn't exist");
        
        climateData[dataId].verified = verified;
        
        emit DataVerified(dataId, verified);
    }
    
    /**
     * @dev Retrieves climate data by ID
     * @param dataId Unique identifier of the data
     * @return timestamp The timestamp when data was recorded
     * @return dataType The type of climate data
     * @return value The recorded climate data value
     * @return location The geographical location of the data point
     * @return provider The address of the data provider
     * @return verified The verification status of the data
     */
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
    
    /**
     * @dev Returns the total number of data points
     * @return Count of all data points
     */
    function getDataCount() public view returns (uint256) {
        return dataIds.length;
    }
}
