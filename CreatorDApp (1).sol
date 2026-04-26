// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CreatorDApp {

    address public creator;
    string  public creatorName;
    uint256 public totalTipsReceived;

    struct Message {
        address author;
        string  text;
        uint256 tipAmount;
        uint256 timestamp;
    }

    Message[] public messages;

    event TipSent(address indexed from, uint256 amount, uint256 timestamp);
    event MessagePosted(address indexed author, string text, uint256 tipAmount, uint256 timestamp);

    constructor(string memory _creatorName) {
        creator     = msg.sender;
        creatorName = _creatorName;
    }

    function sendTip(string memory text) public payable {
        require(msg.value > 0, "You must send some ETH.");
        require(bytes(text).length > 0, "Please include a message.");
        require(bytes(text).length <= 280, "Message too long.");

        messages.push(Message({
            author:    msg.sender,
            text:      text,
            tipAmount: msg.value,
            timestamp: block.timestamp
        }));

        totalTipsReceived += msg.value;

        (bool sent, ) = creator.call{value: msg.value}("");
        require(sent, "Failed to send ETH.");

        emit TipSent(msg.sender, msg.value, block.timestamp);
        emit MessagePosted(msg.sender, text, msg.value, block.timestamp);
    }

    function postMessage(string memory text) public {
        require(bytes(text).length > 0, "Message cannot be empty.");
        require(bytes(text).length <= 280, "Message too long.");

        messages.push(Message({
            author:    msg.sender,
            text:      text,
            tipAmount: 0,
            timestamp: block.timestamp
        }));

        emit MessagePosted(msg.sender, text, 0, block.timestamp);
    }

    function getAllMessages() public view returns (Message[] memory) {
        return messages;
    }

    function getMessage(uint256 index) public view returns (
        address author,
        string  memory text,
        uint256 tipAmount,
        uint256 timestamp
    ) {
        require(index < messages.length, "No message at that index.");
        Message memory m = messages[index];
        return (m.author, m.text, m.tipAmount, m.timestamp);
    }

    function getMessageCount() public view returns (uint256) {
        return messages.length;
    }

    function getCreatorInfo() public view returns (
        address creatorAddress,
        string  memory name,
        uint256 totalTips,
        uint256 messageCount
    ) {
        return (creator, creatorName, totalTipsReceived, messages.length);
    }

}
