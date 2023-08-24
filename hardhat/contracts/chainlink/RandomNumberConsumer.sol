// SPDX-License-Identifier: MIT
// An example of a consumer contract that relies on a subscription for funding.
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";


contract VRFv2Consumer is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords, uint256 block);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event CallbackGasLimitUpdated(uint32 callbackGasLimit);
    event KeyHashUpdated(bytes32 keyhash);
    event ConfirmationUpdated(uint16 confirmation);

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus)
        public s_requests;
    mapping(uint256 => uint256) public blockToRequestId;
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;

    uint256[] public requestIds;
    uint256 public lastRequestId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf/v2/subscription/supported-networks/#configurations
    bytes32 public keyHash;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 public callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 public requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    /**
     * HARDCODED FOR SEPOLIA
     * COORDINATOR: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625
     */
    constructor(
        uint64 subscriptionId,
        address coordinator,
        bytes32 _keyHash
    ) VRFConsumerBaseV2(coordinator) ConfirmedOwner(msg.sender) {
        COORDINATOR = VRFCoordinatorV2Interface(coordinator);
        s_subscriptionId = subscriptionId;
        keyHash = _keyHash;
    }

    function setCallbackGasLimit(
        uint32 _callbackGasLimit
    ) external onlyOwner returns (bool) {
        callbackGasLimit = _callbackGasLimit;
        emit CallbackGasLimitUpdated(callbackGasLimit);
        return true;
    }

    function setKeyHash(bytes32 _keyhash) external onlyOwner returns (bool) {
        keyHash = _keyhash;
        emit KeyHashUpdated(keyHash);
        return true;
    }

    function setConfirmation(
        uint16 _confirmation
    ) external onlyOwner returns (bool) {
        requestConfirmations = _confirmation;
        emit ConfirmationUpdated(requestConfirmations);
        return true;
    }

    function requestRandomWords(
        uint256 block_number,
        uint32 numWords
    ) external onlyOwner returns (uint256 requestId) {
        require(blockToRequestId[block_number] == 0, "This block is requested");

        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        blockToRequestId[block_number] = requestId;
        emit RequestSent(requestId, numWords, block_number);
        return requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(
        uint256 _requestId
    ) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, "request not found");
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}
