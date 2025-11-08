// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title Climate Data Oracle Network
 * @notice A decentralized oracle system for submitting, validating, and accessing
 *         verified climate and environmental data on-chain.
 */
contract Project {
    address public admin;
    uint256 public reportCount;

    struct ClimateReport {
        uint256 id;
        address reporter;
        string location;
        string dataHash;
        uint256 temperature;
        uint256 humidity;
        bool verified;
        uint256 timestamp;
    }

    mapping(uint256 => ClimateReport) public reports;

    event ReportSubmitted(
        uint256 indexed id,
        address indexed reporter,
        string location,
        string dataHash,
        uint256 temperature,
        uint256 humidity
    );

    event ReportVerified(uint256 indexed id, address indexed verifier);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Submit a new climate data report
     * @param _location Name or coordinates of the reporting area
     * @param _dataHash IPFS or SHA256 hash of off-chain data
     * @param _temperature Recorded temperature value
     * @param _humidity Recorded humidity value
     */
    function submitReport(
        string memory _location,
        string memory _dataHash,
        uint256 _temperature,
        uint256 _humidity
    ) external {
        require(bytes(_location).length > 0, "Location required");
        require(bytes(_dataHash).length > 0, "Data hash required");

        reportCount++;
        reports[reportCount] = ClimateReport({
            id: reportCount,
            reporter: msg.sender,
            location: _location,
            dataHash: _dataHash,
            temperature: _temperature,
            humidity: _humidity,
            verified: false,
            timestamp: block.timestamp
        });

        emit ReportSubmitted(reportCount, msg.sender, _location, _dataHash, _temperature, _humidity);
    }

    /**
     * @notice Verify a submitted report (admin only)
     * @param _id Report ID to verify
     */
    function verifyReport(uint256 _id) external onlyAdmin {
        ClimateReport storage report = reports[_id];
        require(!report.verified, "Already verified");
        report.verified = true;

        emit ReportVerified(_id, msg.sender);
    }

    /**
     * @notice Retrieve a specific climate report
     * @param _id Report ID
     */
    function getReport(uint256 _id) external view returns (ClimateReport memory) {
        require(_id > 0 && _id <= reportCount, "Invalid report ID");
        return reports[_id];
    }
}
// 
End
// 
