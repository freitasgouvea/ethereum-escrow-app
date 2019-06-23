pragma solidity 0.5.1.;

contract ServiceSmartContractWithArbitration {
    address payable provider;
    address payable arbitrator;
    uint256 balance;
    uint256 totalOfSells;
    uint256 numberOfSells;
    uint256 numberOfDeliveries;
    uint256 numberOfFails;
    uint256 valueToTransfer;

    service [] listOfSells;
    dispute [] listOfDisputes;
    
    struct service {
        address payable provider;
        address payable contractor;
        address contractHash;
        bool providerSign;
        uint256 providerSignDate;
        bool contractorSign;
        uint256 contractorSignDate;
        uint256 billValue;
        uint256 dateOfPayment;
        uint256 dateOfDelivery;
        uint256 dateOfTerm;
        bool servicePayed;
        bool contractSigned;
        bool serviceCanceled;
        bool serviceDelivered;
        bool serviceDisputed;
        bool serviceArbitraded;
        bool serviceConcluded;
    }
    
    struct dispute {
        uint256 serviceId;
        address payable arbitrator;
        address payable provider;
        address payable contractor;
        uint256 valueOfADispute;
        bool disputeProcessed;
        bool resultOfDispute;
        uint256 dateOfArbitration;
    }
    
    constructor (address payable _providerWallet, address payable _arbitratorWallet ) public {
        provider = _providerWallet;
        arbitrator = _arbitratorWallet;
    }
    
    function registrerService (address payable _contractor, address _contractHash, uint256 _billValue) public {
        require (msg.sender == provider);
        listOfSells.push(service(provider, _contractor, _contractHash, true, now, false, 0, _billValue, 0, 0, 0, false, false, false, false, false, false, false));
    }
    
    function signContract (uint serviceId, address _contractHash) public {
        require (msg.sender == listOfSells[serviceId].contractor);
        require (_contractHash == listOfSells[serviceId].contractHash);
        listOfSells[serviceId].contractorSign = true;
        listOfSells[serviceId].contractorSignDate = now;
    }
    
    function payService (uint256 serviceId) public payable {
        require (listOfSells[serviceId].billValue == msg.value);
        require (listOfSells[serviceId].servicePayed == false);
        require (listOfSells[serviceId].serviceCanceled == false);
        listOfSells[serviceId].dateOfPayment = now;
        listOfSells[serviceId].servicePayed = true;
        numberOfSells ++;
        balance += msg.value;
    }
    
    function cancelService (uint256 serviceId) public payable {
        require (msg.sender == provider);
        listOfSells[serviceId].serviceCanceled = true;
        listOfSells[serviceId].contractor.transfer(listOfSells[serviceId].billValue);
        balance -= listOfSells[serviceId].billValue;
        numberOfFails ++;
    }
    
    function deliveryAService(uint256 serviceId) public {
        require (msg.sender == provider);
        require (true == listOfSells[serviceId].servicePayed);
        listOfSells[serviceId].serviceDelivered = true;
        listOfSells[serviceId].dateOfDelivery = now;
    }
    
    function acceptService(uint256 serviceId) public payable {
        require (msg.sender == listOfSells[serviceId].contractor);
        provider.transfer(listOfSells[serviceId].billValue);
        listOfSells[serviceId].serviceConcluded = true;
        listOfSells[serviceId].dateOfTerm = now;
        balance -= listOfSells[serviceId].billValue;
        numberOfDeliveries ++;
    }
    
    function rejectService(uint256 serviceId) public {
        require (msg.sender == listOfSells[serviceId].contractor);
        require (true == listOfSells[serviceId].serviceDelivered);
        listOfDisputes.push(dispute(serviceId, arbitrator, provider, listOfSells[serviceId].contractor,listOfSells[serviceId].billValue, false, false, 0));
        listOfSells[serviceId].serviceDisputed = true;
    }
    
    function disputeToContractor(uint256 disputeId) public payable {
        require (msg.sender == arbitrator);
        listOfDisputes[disputeId].contractor.transfer(listOfDisputes[disputeId].valueOfADispute);
        listOfSells[listOfDisputes[disputeId].serviceId].dateOfTerm = now;
        listOfSells[listOfDisputes[disputeId].serviceId].serviceArbitraded = true;
        listOfSells[listOfDisputes[disputeId].serviceId].serviceConcluded = true;
        listOfDisputes[disputeId].disputeProcessed = true;
        listOfDisputes[disputeId].resultOfDispute = true;
        balance -= listOfDisputes[disputeId].valueOfADispute;
        numberOfFails ++;
    }
    
    function disputeToProvider(uint256 disputeId) public payable {
        require (msg.sender == arbitrator);
        provider.transfer(listOfDisputes[disputeId].valueOfADispute);
        listOfSells[listOfDisputes[disputeId].serviceId].dateOfTerm = now;
        listOfSells[listOfDisputes[disputeId].serviceId].serviceArbitraded = true;
        listOfSells[listOfDisputes[disputeId].serviceId].serviceConcluded = true;
        listOfDisputes[disputeId].disputeProcessed = true;
        listOfDisputes[disputeId].resultOfDispute = false;
        balance -= listOfDisputes[disputeId].valueOfADispute;
        numberOfDeliveries ++;
    }
    
    function showBill(uint256 serviceId) public view returns (address payable, address payable, uint256, uint256, bool) {
        return (listOfSells[serviceId].provider, listOfSells[serviceId].contractor, listOfSells[serviceId].billValue, listOfSells[serviceId].dateOfPayment, listOfSells[serviceId].servicePayed);
    }
    
    function showServiceStatus(uint256 serviceId) public view returns (bool, bool, bool, bool, bool,bool) {
        return (listOfSells[serviceId].contractSigned, listOfSells[serviceId].serviceCanceled, listOfSells[serviceId].serviceDelivered, listOfSells[serviceId].serviceDisputed, listOfSells[serviceId].serviceArbitraded, listOfSells[serviceId].serviceConcluded);
    }
    
    function showContract (uint256 serviceId) public view returns (address, address payable, bool, uint256, address payable, bool, uint256) {
        return (listOfSells[serviceId].contractHash, listOfSells[serviceId].provider, listOfSells[serviceId].providerSign, listOfSells[serviceId].providerSignDate, listOfSells[serviceId].contractor, listOfSells[serviceId].contractorSign, listOfSells[serviceId].contractorSignDate); 
    }
    
    function showDispute(uint256 disputeId) public view returns (uint256, address payable, address payable, uint256, bool, bool) {
        return (listOfDisputes[disputeId].serviceId, listOfDisputes[disputeId].provider, listOfDisputes[disputeId].contractor, listOfDisputes[disputeId].valueOfADispute, listOfDisputes[disputeId].disputeProcessed, listOfDisputes[disputeId].resultOfDispute);
    }
    
    function showStatus() public view returns (uint256, uint256, uint256, uint256, uint256) {
        return (balance, totalOfSells, numberOfSells, numberOfDeliveries, numberOfFails);
    }
    
    function drawSells(uint256 _value) public payable {
        require (msg.sender == provider);
        valueToTransfer = _value;
        provider.transfer(valueToTransfer);
        balance -= _value;
    }
}
