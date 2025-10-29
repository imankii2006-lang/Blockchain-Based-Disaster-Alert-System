// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Blockchain-Based Disaster Alert System
 * @dev Smart contract for managing disaster alerts with verification and response tracking
 */
contract Project {
    
    struct DisasterAlert {
        uint256 id;
        address reporter;
        string disasterType;
        string location;
        string severity; // "Low", "Medium", "High", "Critical"
        string description;
        uint256 timestamp;
        bool isVerified;
        address verifiedBy;
        bool isActive;
    }
    
    struct EmergencyResponse {
        uint256 alertId;
        address responder;
        string responseType;
        string status;
        uint256 timestamp;
    }
    
    // State variables
    address public admin;
    uint256 public alertCounter;
    uint256 public responseCounter;
    
    mapping(uint256 => DisasterAlert) public alerts;
    mapping(uint256 => EmergencyResponse[]) public responses;
    mapping(address => bool) public authorizedVerifiers;
    
    // Events
    event AlertCreated(uint256 indexed alertId, address indexed reporter, string disasterType, string severity);
    event AlertVerified(uint256 indexed alertId, address indexed verifier);
    event ResponseAdded(uint256 indexed alertId, address indexed responder, string responseType);
    event AlertDeactivated(uint256 indexed alertId);
    
    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    
    modifier onlyVerifier() {
        require(authorizedVerifiers[msg.sender] || msg.sender == admin, "Not authorized to verify");
        _;
    }
    
    constructor() {
        admin = msg.sender;
        authorizedVerifiers[msg.sender] = true;
    }
    
    /**
     * @dev Core Function 1: Create a new disaster alert
     * @param _disasterType Type of disaster (e.g., "Earthquake", "Flood", "Fire")
     * @param _location Location of the disaster
     * @param _severity Severity level
     * @param _description Detailed description
     */
    function createAlert(
        string memory _disasterType,
        string memory _location,
        string memory _severity,
        string memory _description
    ) public returns (uint256) {
        alertCounter++;
        
        alerts[alertCounter] = DisasterAlert({
            id: alertCounter,
            reporter: msg.sender,
            disasterType: _disasterType,
            location: _location,
            severity: _severity,
            description: _description,
            timestamp: block.timestamp,
            isVerified: false,
            verifiedBy: address(0),
            isActive: true
        });
        
        emit AlertCreated(alertCounter, msg.sender, _disasterType, _severity);
        return alertCounter;
    }
    
    /**
     * @dev Core Function 2: Verify a disaster alert (only authorized verifiers)
     * @param _alertId ID of the alert to verify
     */
    function verifyAlert(uint256 _alertId) public onlyVerifier {
        require(_alertId > 0 && _alertId <= alertCounter, "Invalid alert ID");
        require(alerts[_alertId].isActive, "Alert is not active");
        require(!alerts[_alertId].isVerified, "Alert already verified");
        
        alerts[_alertId].isVerified = true;
        alerts[_alertId].verifiedBy = msg.sender;
        
        emit AlertVerified(_alertId, msg.sender);
    }
    
    /**
     * @dev Core Function 3: Add emergency response to an alert
     * @param _alertId ID of the alert
     * @param _responseType Type of response (e.g., "Medical", "Rescue", "Evacuation")
     * @param _status Current status of response
     */
    function addResponse(
        uint256 _alertId,
        string memory _responseType,
        string memory _status
    ) public {
        require(_alertId > 0 && _alertId <= alertCounter, "Invalid alert ID");
        require(alerts[_alertId].isActive, "Alert is not active");
        
        responseCounter++;
        
        EmergencyResponse memory newResponse = EmergencyResponse({
            alertId: _alertId,
            responder: msg.sender,
            responseType: _responseType,
            status: _status,
            timestamp: block.timestamp
        });
        
        responses[_alertId].push(newResponse);
        
        emit ResponseAdded(_alertId, msg.sender, _responseType);
    }
    
    // Additional helper functions
    
    function addVerifier(address _verifier) public onlyAdmin {
        authorizedVerifiers[_verifier] = true;
    }
    
    function removeVerifier(address _verifier) public onlyAdmin {
        authorizedVerifiers[_verifier] = false;
    }
    
    function deactivateAlert(uint256 _alertId) public onlyAdmin {
        require(_alertId > 0 && _alertId <= alertCounter, "Invalid alert ID");
        alerts[_alertId].isActive = false;
        emit AlertDeactivated(_alertId);
    }
    
    function getAlert(uint256 _alertId) public view returns (DisasterAlert memory) {
        require(_alertId > 0 && _alertId <= alertCounter, "Invalid alert ID");
        return alerts[_alertId];
    }
    
    function getResponses(uint256 _alertId) public view returns (EmergencyResponse[] memory) {
        return responses[_alertId];
    }
    
    function getActiveAlerts() public view returns (uint256[] memory) {
        uint256 activeCount = 0;
        for (uint256 i = 1; i <= alertCounter; i++) {
            if (alerts[i].isActive) {
                activeCount++;
            }
        }
        
        uint256[] memory activeAlertIds = new uint256[](activeCount);
        uint256 index = 0;
        for (uint256 i = 1; i <= alertCounter; i++) {
            if (alerts[i].isActive) {
                activeAlertIds[index] = i;
                index++;
            }
        }
        
        return activeAlertIds;
    }
}
