pragma solidity ^0.8.9;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./owner/Operator.sol";

contract ProfitDistribution is Operator {
    using SafeERC20 for IERC20;
    
    string public name = "ProfitDistribution"; // call it ProfitDistribution
    
    IERC20 public depositToken;
    address public burnAddress;
    uint256 public totalStaked;
    uint256 public depositFee;
    uint256 public totalBurned;
    uint256 public maxWithdrawFee;
    uint256 public feePeriod;

    //uint256[] public lockMultiplers; for later usage
    uint256 public totalAllocation;
    
    address[] public stakers;

    struct RewardInfo {
        IERC20 token;
        uint256 rewardsPerEpoch;
        uint256 totalRewards;
        bool isActive;
        uint256 distributedAmount;
        uint256 LastDistributedAmountPerAlloc;
        uint256[] rewardPerAllocHistory;
    }

    struct UserInfo {
        uint256 balance;
        uint256 allocation;
        bool hasStaked;
        bool isStaking;
        uint256 lastStakedTime;

        mapping(uint256=> uint256) lastSnapShotIndex; // Maps rewardPoolId to lastSnapshotindex
        mapping(uint256 => uint256) pendingRewards; // Maps rewardPoolId to amount
    }


    RewardInfo[] public rewardInfo;

    

    mapping(address => UserInfo) public userInfo;

    // in constructor pass in the address for reward token 1 and reward token 2
    // that will be used to pay interest
    constructor(IERC20 _depositToken) {
        depositToken = _depositToken;
        burnAddress = 0x000000000000000000000000000000000000dEaD;
        //deposit fee default at 1%
        depositFee = 1000;

        //max withdraw fee default 7%

        maxWithdrawFee = 7000;
        
        feePeriod = 7 days;

        //totalBurned to 0 

        totalBurned = 0;
    }

    //Events 

    event UpdateDepositFee(uint256 _depositFee);
    event UpdateMaxWithdrawFee(uint256 _Fee);

    event AddReward(IERC20 _token);
    event UpdateBurnAddress(address _burnAddress);                    
    event UpdateRewardsPerEpoch(uint256 _rewardId, uint256 _amount);

    event RewardIncrease(uint256 _rewardId, uint256 _amount);
    event RewardDecrease(uint256 _rewardId, uint256 _amount);

    event TotalStakedIncrease(uint256 _amount);
    event TotalStakedDecrease(uint256 _amount);

    event UserStakedIncrease(address _user, uint256 _amount);
    event UserStakedDecrease(address _user, uint256 _amount);

    event PendingRewardIncrease(address _user, uint256 _rewardId, uint256 _amount);
    event PendingRewardClaimed(address _user);

    event fees(address _user, uint256 fees);
  

    //update pending rewards modifier
    modifier updatePendingRewards(address _sender){
        
        UserInfo storage user = userInfo[_sender];

        for(uint256 i = 0; i < rewardInfo.length; ++i){
            RewardInfo storage reward = rewardInfo[i];
            
            //calculate pending rewards
            user.pendingRewards[i] = earned(_sender, i);
            user.lastSnapShotIndex[i] = reward.rewardPerAllocHistory.length -1;
        }

        _;
    }

    /*this function calculates the earnings of user over the last recorded 
    epoch  to the most recent epoch using average rewardPerAllocation over time*/

    function earned(address _sender, uint256 _rewardId) public view returns (uint256) {

        UserInfo storage user = userInfo[_sender];
        RewardInfo storage reward = rewardInfo[_rewardId];

        uint256 latestRPA = reward.LastDistributedAmountPerAlloc;
        uint256 storedRPA = reward.rewardPerAllocHistory[user.lastSnapShotIndex[_rewardId]];

        return user.allocation*(latestRPA - storedRPA)/(1e18)+ user.pendingRewards[_rewardId];
    }

    //update deposit fee

    function updateDepositFee(uint256 _depositFee) external onlyOperator {
        require(_depositFee < 3000, "deposit fee too high");
        depositFee = _depositFee;
        emit UpdateDepositFee(_depositFee);
    }

    function updateMaxWithdrawFee(uint256 _Fee) external onlyOperator {
        require(_Fee < 10000, "deposit fee too high");
        maxWithdrawFee = _Fee;
        emit UpdateMaxWithdrawFee(_Fee);
    }

    function updateFeeTime(uint256 _time) external onlyOperator {
        require(_time < 30 days, "deposit fee too high");
        feePeriod = _time* 1 hours;
    }

    //add more reward tokens
    function addReward(IERC20 _token) external onlyOperator {
        rewardInfo.push(RewardInfo({
            token: _token,
            rewardsPerEpoch: 0,
            totalRewards: 0,
            isActive: false,
            distributedAmount:0,
            LastDistributedAmountPerAlloc:0,
            rewardPerAllocHistory: new uint256[](1)
        }));

        emit AddReward(_token);
    }

    // Update burn address
    function updateBurnAddress(address _burnAddress) external onlyOperator {
        burnAddress = _burnAddress;
        emit UpdateBurnAddress(_burnAddress);
    }

    // update the rewards per Epoch of each reward token
    function updateRewardsPerEpoch(uint256 _rewardId, uint256 _amount) external onlyOperator {
        RewardInfo storage reward = rewardInfo[_rewardId];
        
        // checking amount
        require(_amount < reward.totalRewards,"amount must be lower than totalRewards");

        // update rewards per epoch
        reward.rewardsPerEpoch = _amount;

        if (_amount == 0) {
            reward.isActive = false;
        } else {
            reward.isActive = true;
        }

        emit UpdateRewardsPerEpoch(_rewardId, _amount);
    }

    // supply rewards to contract
    function supplyRewards(uint256 _rewardId, uint256 _amount) external onlyOperator {
        RewardInfo storage reward = rewardInfo[_rewardId];

        require(_amount > 0, "amount must be > 0");

        // Update the rewards balance in map
        reward.totalRewards += _amount;
        emit RewardIncrease(_rewardId, _amount);

        // update status for tracking
        if (reward.totalRewards > 0 && reward.totalRewards > reward.rewardsPerEpoch) {
            reward.isActive = true;
        }

        // Transfer reward tokens to contract
        reward.token.safeTransferFrom(msg.sender, address(this), _amount);

        
    }
    

    //withdraw rewards out of contract
    function withdrawRewards(uint256 _rewardId, uint256 _amount) external onlyOperator {
        RewardInfo storage reward = rewardInfo[_rewardId];

        require(_amount <= reward.totalRewards, "amount should be less than total rewards");

        // Update the rewards balance in map
        reward.totalRewards -= _amount;
        emit RewardDecrease(_rewardId, _amount);

        // update status for tracking
        if (reward.totalRewards == 0 || reward.totalRewards < reward.rewardsPerEpoch) {
            reward.isActive = false;
        }

        // Transfer reward tokens out of contract 
        reward.token.safeTransfer(msg.sender, _amount);
    }

    function stakeTokens(uint256 _amount) external updatePendingRewards(msg.sender){
        address _sender = msg.sender;
        UserInfo storage user = userInfo[_sender];

        require(_amount > 0, "can't stake 0");
        user.lastStakedTime = block.timestamp;
        // 1% fee calculation 
        uint256 feeAmount = _amount * depositFee / 100000;
        uint256 depositAmount = _amount - feeAmount;

        //update totalBurned
        totalBurned += feeAmount;

        // Update the staking balance in map
        user.balance += depositAmount;
        emit UserStakedIncrease(_sender, depositAmount);

        //update allocation 
        user.allocation += depositAmount;
        totalAllocation += depositAmount;

        //update TotalStaked
        totalStaked += depositAmount;
        emit TotalStakedIncrease(depositAmount);

        // Add user to stakers array if they haven't staked already
        if(!user.hasStaked) {
            stakers.push(_sender);
        }

        // Update staking status to track
        user.isStaking = true;
        user.hasStaked = true;

        // Transfer based tokens to contract for staking
        depositToken.safeTransferFrom(_sender, address(this), _amount);

        // burn based
        depositToken.safeTransfer(burnAddress, feeAmount);
    }
        
    // allow user to unstake total balance and withdraw USDC from the contract
    function unstakeTokens(uint256 _amount) external updatePendingRewards(msg.sender) {
        address _sender = msg.sender;
        UserInfo storage user = userInfo[_sender];

        require(_amount > 0, "can't unstake 0");

        //check if amount is less than balance
        require(_amount <= user.balance, "staking balance too low");

        //calculate fees
        uint current_fee = 0;
        if (feePeriod > (block.timestamp - user.lastStakedTime)){
            current_fee = (feePeriod - (block.timestamp - user.lastStakedTime))*(1e18)/(feePeriod)*maxWithdrawFee/1e18;
            emit fees(msg.sender, current_fee);
        }
      

        uint256 feeAmount = _amount * current_fee / 100000;
        uint256 WithdrawAmount = _amount - feeAmount;

        //update user balance
        user.balance -= _amount;
        emit UserStakedDecrease(_sender, _amount);

        //update allocation 
        user.allocation -= _amount;
        totalAllocation -= _amount;

        //update totalStaked
        totalStaked -= _amount;
        emit TotalStakedDecrease(_amount);
    
        // update the staking status
        if (user.balance == 0) {
            user.isStaking = false;
        }
        
        // transfer staked tokens out of this contract to the msg.sender
        depositToken.safeTransfer(_sender, WithdrawAmount);
        if (feeAmount > 0){

            totalBurned += feeAmount;
            depositToken.safeTransfer(burnAddress, feeAmount);
        }
        
    }

    function issueInterestToken(uint256 _rewardId) public onlyOperator {
        RewardInfo storage reward = rewardInfo[_rewardId];
        require(reward.isActive, "No rewards");

        //update distributed amount and reward per allocations
        reward.distributedAmount += reward.rewardsPerEpoch;

        uint256 thisEpochRPA = reward.rewardsPerEpoch*(1e18)/totalAllocation;

        reward.LastDistributedAmountPerAlloc = reward.LastDistributedAmountPerAlloc + thisEpochRPA;
        reward.rewardPerAllocHistory.push(reward.LastDistributedAmountPerAlloc);
        
        if(reward.totalRewards > 0) {
                //update totalRewards 
                reward.totalRewards -= reward.rewardsPerEpoch;
                emit RewardDecrease(_rewardId, reward.rewardsPerEpoch);
        }
            

        if (reward.totalRewards == 0 || reward.totalRewards < reward.rewardsPerEpoch) {
            reward.isActive = false;
        }
    }

    //get pending rewards
    function getPendingRewards(uint256 _rewardId, address _user) external view returns(uint256) {
         UserInfo storage user = userInfo[_user];
         return user.pendingRewards[_rewardId];
    }

        //get pending rewards
    function getLastSnapShotIndex(uint256 _rewardId, address _user) external view returns(uint256) {
         UserInfo storage user = userInfo[_user];
         return user.lastSnapShotIndex[_rewardId];
    }

    
    //collect rewards

    function collectRewards() external updatePendingRewards(msg.sender) {
        
        address _sender = msg.sender;

        
        UserInfo storage user = userInfo[_sender];

        //update pendingRewards and collectRewards

        //loop through the reward IDs
        for(uint256 i = 0; i < rewardInfo.length; ++i){
            //if pending rewards is not 0 
            if (user.pendingRewards[i] > 0){
                
                RewardInfo storage reward = rewardInfo[i];
                uint256 rewardsClaim = user.pendingRewards[i];
                //reset pending rewards 
                user.pendingRewards[i] = 0;
                
                //send rewards
                emit PendingRewardClaimed(_sender);
                reward.token.safeTransfer(_sender, rewardsClaim);
            }
        }
    }

    //get the pool share of a staker
    function getPoolShare(address _user) public view returns(uint256) {
        return (userInfo[_user].allocation * (1e18)) / totalStaked;
    }

    function distributeRewards() external onlyOperator {
        uint256 length = rewardInfo.length;
        for (uint256 i = 0; i < length; ++ i) {
            if (rewardInfo[i].isActive) {
                issueInterestToken(i);
            }
        }
    }

}