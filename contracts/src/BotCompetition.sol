/* Copyright (C) wighawag <wighawag@gmail.com> - All Rights Reserved */
pragma solidity 0.4.18;

import "Bot.sol";

contract Competitions {

	bytes32[10] world; //256 / 3bit = 85.33333...  / 3 row = 28.33333.... 
	struct BotInfo{
		Bot code;

		uint8 x;
		uint8 y;
		uint8 dir;
	}

	BotInfo bot1;
	BotInfo bot2;


	address owner;

	function BotCompetition(){
		owner = msg.sender;
	}

	function test_setup(Bot bot1_code, Bot bot2_code) public{ //TODO set it independtly with bets and hash to not allow the other to compute before hand
		require(owner == msg.sender);


		bot1.code = bot1_code;
		bot2.code = bot2_code;

		bot1.x = 0;
		bot1.y = 0;
		bot2.x = 27;
		bot2.y = 29;
		bot2.dir = 2; 
	}

	function getTenthOfTheWorld(uint8 index) public returns(bytes32 data){
		return world[index];
	}


	function step() public {
		

		bytes32[10] memory mworld = world;

		uint8 bot1_x = bot1.x;
		uint8 bot1_y = bot1.y;
		uint8 bot1_dir = bot1.dir;

		uint8 bot2_x = bot2.x;
		uint8 bot2_y = bot2.y;
		uint8 bot2_dir = bot2.dir;

		uint8 change = bot1.code.execute(mworld, bot1_x, bot1_y, bot1_dir, bot2_x, bot2_y, bot2_dir);
		if(change == 1){ //left
			if(bot1_dir == 0){
				bot1_dir = 3;
			}else{
				bot1_dir = bot1_dir - 1;
			}
		}else if(change == 2){ //right
			if(bot1_dir == 3){
				bot1_dir = 0;
			}else{
				bot1_dir = bot1_dir + 1;
			}
		}	
		if(bot1_dir == 0){
			if(bot1_x == 27){
				//dead ?
			}else{
				bot1_x = bot1_x + 1;
			}
		}else if(bot1_dir == 1){
			if(bot1_y == 29){
				//dead ?
			}else{
				bot1_y = bot1_y + 1;
			}
		}else if(bot1_dir == 2){
			if(bot1_x == 0){
				//dead ?
			}else{
				bot1_x = bot1_x - 1;
			}
		}else if(bot1_dir == 3){
			if(bot1_y == 0){
				//dead ?
			}else{
				bot1_y = bot1_y - 1;
			}
		}

		var bot1_index = bot1_y * 28 + bot1_x;
		if(mworld[bot1_index] != 0){
			//dead
		}else{
			mworld[bot1_index] = 1; //bot1
		}


	}

	
}

