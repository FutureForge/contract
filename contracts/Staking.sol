// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract Staking is Ownable {
    //Structs
    struct Stake {
        uint256 amount; 
        uint256 timestamp;
    }

    //State variables
    mapping(address => Stake[]) public stakes;
    uint256 public rewardRate; 
    uint256 public lockPeriod;

    // Events
    event Staked(address indexed user, uint256 amount, uint256 timestamp);
    event Withdrawn(address indexed user, uint256 amount, uint256 reward);
    event UpdateLock(uint256 _lockPeriod);
    event UpdateReward(uint256 _rewardRate);

    constructor
    (uint256 _rewardRate, uint256 _lockPeriod) 
    Ownable(msg.sender) 
    {
        rewardRate = _rewardRate;
        lockPeriod = _lockPeriod;
    }


    //Staking function
    function stake ()external payable {
        require(msg.value > 0, "Stake amount sshould be greater than 0");
        stakes[msg.sender].push(Stake({
            amount: msg.value,
            timestamp: block.timestamp
        }));

        emit Staked(msg.sender, msg.value, block.timestamp);
    }

    //Withdrawal of Stake
    function withdrawal (uint256 stakeIndex) external {
        require(stakeIndex < stakes[msg.sender].length, "Invalid stake index");
        Stake memory userStake = stakes[msg.sender][stakeIndex];

        require(userStake.amount >0,"User stake withdrawn");
        require(block.timestamp >= userStake.timestamp + lockPeriod, "Stake is still locked");

        // Reward Calculation
        uint256 reward = (userStake.amount * rewardRate) / 100;
        uint256 totalAmount = userStake.amount + reward;

        //Stake removal
        stakes[msg.sender][stakeIndex].amount = 0;
        payable(msg.sender).transfer(totalAmount);

        emit Withdrawn(msg.sender, userStake.amount, reward);
    }

    //Unstaking before lock ends
    function unstake (uint256 stakeIndex) external {
        require(stakeIndex < stakes[msg.sender].length, "Invalid stake index");
        Stake memory userStake = stakes[msg.sender][stakeIndex];

        require(userStake.amount >0,"User stake withdrawn");

        //penalty calculation
        uint256 penalty = (userStake.amount * 2) / 100;
        uint256 amountAfterPenalty = userStake.amount - penalty;

        //Stake removal
        stakes[msg.sender][stakeIndex].amount = 0;
        payable(msg.sender).transfer(amountAfterPenalty);

        emit Withdrawn(msg.sender, amountAfterPenalty, penalty);
    }

    //This function is done by the deployer of the contract
    function withdrawFees() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function setLockPeriod (uint256 _lockPeriod) external onlyOwner{
        lockPeriod = _lockPeriod;
        emit UpdateLock(_lockPeriod);
    }

    function setRewardRate(uint256 _rewardRate) external onlyOwner{
        rewardRate = _rewardRate;
        emit UpdateReward(_rewardRate);
    }

    //Function to acccept ETH
    receive() external payable {}
}