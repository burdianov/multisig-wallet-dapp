// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract MultisigWallet {
    address[] public approvers;
    uint256 public quorum;

    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }
    Transfer[] public transfers;

    mapping(address => mapping(uint256 => bool)) public approvals;

    constructor(address[] memory _approvers, uint256 _quorum) {
        approvers = _approvers;
        quorum = _quorum;
    }

    modifier onlyApprover() {
        bool allowed = false;
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
                break;
            }
        }
        require(allowed, "only an approver can call this function");
        _;
    }

    function getApprovers() external view returns (address[] memory) {
        return approvers;
    }

    function getApprovalsByApprover(address approver)
        external
        view
        onlyApprover
        returns (bool[] memory userApprovals)
    {
        uint256 transfersLength = transfers.length;
        userApprovals = new bool[](transfersLength);

        for (uint256 i = 0; i < transfersLength; ++i) {
            userApprovals[i] = approvals[approver][i];
        }
    }

    function getTransfers() external view returns (Transfer[] memory) {
        return transfers;
    }

    function createTransfer(uint256 amount, address payable to)
        external
        onlyApprover
    {
        transfers.push(Transfer(transfers.length, amount, to, 0, false));
    }

    function approveTransfer(uint256 id) external onlyApprover {
        require(!transfers[id].sent, "transfer has already been sent");
        require(
            !approvals[msg.sender][id],
            "transfer has already been approved"
        );

        approvals[msg.sender][id] = true;
        transfers[id].approvals++;

        if (transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint256 amount = transfers[id].amount;
            to.transfer(amount);
        }
    }

    receive() external payable {}
}
