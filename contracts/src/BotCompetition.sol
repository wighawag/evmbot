/* Copyright (C) wighawag <wighawag@gmail.com> - All Rights Reserved */
pragma solidity 0.4.18;

import "Bot.sol";

contract BotCompetition {

	
	struct BotInfo{
		Bot code;

		uint8 x;
		uint8 y;
		uint8 dir;
	}


	struct BotState{
		uint8 x;
		uint8 y;
		uint8 dir;
	}


	struct World{
		uint16 turn;
		BotInfo bot1;
		BotInfo bot2;
		bytes32[10] data; //256 / 3bit = 85.33333...  / 3 row = 28.33333.... 
	}


	mapping(bytes32 => World) worlds;

	address owner;

	function BotCompetition(){
		owner = msg.sender;
	}

	function test_setup(bytes32 worldId, Bot bot1_code, Bot bot2_code) public{ //TODO set it independtly with bets and hash to not allow the other to compute before hand
		require(owner == msg.sender);

		worlds[worldId].bot1.code = bot1_code;
		worlds[worldId].bot2.code = bot2_code;

		worlds[worldId].bot1.x = 0;
		worlds[worldId].bot1.y = 0;
		worlds[worldId].bot1.dir = 0;

		worlds[worldId].data[0] = setBit(worlds[worldId].data[0],1);
		

		worlds[worldId].bot2.x = 27;
		worlds[worldId].bot2.y = 29;
		worlds[worldId].bot2.dir = 2; 

		worlds[worldId].data[9] = setBit(worlds[worldId].data[9],253+2);//setBit(worlds[worldId].data[0],1);//
	}

	function getTenthOfTheWorld(bytes32 worldId, uint8 index) public constant returns(bytes32 data){
		return worlds[worldId].data[index];
	}


	function step(bytes32 worldId) public {
		bytes32[10] memory mworld = worlds[worldId].data;
		uint16 mturn = worlds[worldId].turn;

		BotState memory mbot1 = BotState({
			x : worlds[worldId].bot1.x,
			y : worlds[worldId].bot1.y,
			dir : worlds[worldId].bot1.dir
		});

		BotState memory mbot2 = BotState({
			x : worlds[worldId].bot2.x,
			y : worlds[worldId].bot2.y,
			dir : worlds[worldId].bot2.dir
		});

		uint8 change = 0;

		while(msg.gas > 70000){
			change = worlds[worldId].bot1.code.execute.gas(20000)(mworld, mbot1.x, mbot1.y, mbot1.dir, mbot2.x, mbot2.y, mbot2.dir, mturn); 
			process(mworld,mbot1,change, 1);
			
			change = worlds[worldId].bot2.code.execute.gas(20000)(mworld, mbot2.x, mbot2.y, mbot2.dir, mbot1.x, mbot1.y, mbot1.dir, mturn);
			process(mworld,mbot2,change, 2);	

			mturn++;
		}

		
		//TODO loop

		worlds[worldId].data = mworld;

		worlds[worldId].turn = mturn;

		worlds[worldId].bot1.x = mbot1.x;
		worlds[worldId].bot1.y = mbot1.y;
		worlds[worldId].bot1.dir = mbot1.dir;

		worlds[worldId].bot2.x = mbot2.x;
		worlds[worldId].bot2.y = mbot2.y;
		worlds[worldId].bot2.dir = mbot2.dir;
	}

	function process(bytes32[10] memory mworld, BotState memory bot, uint8 change, uint8 color) internal{
		if(change == 1){ //left
			if(bot.dir == 0){
				bot.dir = 3;
			}else{
				bot.dir = bot.dir - 1;
			}
		}else if(change == 2){ //right
			if(bot.dir == 3){
				bot.dir = 0;
			}else{
				bot.dir = bot.dir + 1;
			}
		}	
		if(bot.dir == 0){
			if(bot.x == 27){
				//dead ?
			}else{
				bot.x = bot.x + 1;
			}
		}else if(bot.dir == 1){
			if(bot.y == 29){
				//dead ?
			}else{
				bot.y = bot.y + 1;
			}
		}else if(bot.dir == 2){
			if(bot.x == 0){
				//dead ?
			}else{
				bot.x = bot.x - 1;
			}
		}else if(bot.dir == 3){
			if(bot.y == 0){
				//dead ?
			}else{
				bot.y = bot.y - 1;
			}
		}

		uint16 bot_index = bot.y * 28 + bot.x;
		uint8 bytesIndex = uint8(bot_index / 10);
		uint8 index = uint8(bot_index - uint16(bytesIndex) * 10);
		
		if(getBit(mworld[bytesIndex],index*3+1) != false || getBit(mworld[bytesIndex],index*3+2) != false){
			//dead
		}else{
			mworld[bytesIndex] = setBit(mworld[bytesIndex],index*3+color);
		}
	}



	function and(bytes32 a, bytes32 b) internal returns (bytes32) {
        return a & b;
    }
    
    function or(bytes32 a, bytes32 b) internal returns (bytes32) {
        return a | b;
    }
    
    function xor(bytes32 a, bytes32 b) internal returns (bytes32) {
        return a ^ b;
    }
    
    function negate(bytes32 a) internal returns (bytes32) {
        return a ^ allOnes();
    }
    
    
    function shiftLeft(bytes32 a, uint8 n) internal returns (bytes32) {
        var shifted = uint256(a) * uint256(2) ** n;
        return bytes32(shifted);
    }
    
    function shiftRight(bytes32 a, uint8 n) internal returns (bytes32) {
        var shifted = uint256(a) / uint256(2) ** n;
        return bytes32(shifted);
    }
    
    function getFirstN(bytes32 a, uint8 n) internal returns (bytes32) {
        var nOnes = bytes32(2 ** n - 1);
        var mask = shiftLeft(nOnes, uint8(256 - n)); // Total 256 bits
        return a & mask;
    } 
    
    function getLastN(bytes32 a, uint8 n) internal returns (bytes32) {
        var lastN = uint256(a) % 2 ** n;
        return bytes32(lastN);
    } 
    
    // Sets all bits to 1
    function allOnes() internal returns (bytes32) {
        return bytes32(-1); // 0 - 1, since data type is unsigned, this results in all 1s.
    }
    
    // Get bit value at position
    function getBit(bytes32 a, uint8 n) internal returns (bool) {
        return a & bytes32(uint256(2)**n) != 0;
    }
    
    // Set bit value at position
    function setBit(bytes32 a, uint8 n) internal returns (bytes32) {
        return a | bytes32(uint256(2)**n);
    }
    
    // Set the bit into state "false"
    function clearBit(bytes32 a, uint8 n) internal returns (bytes32) {
        bytes32 mask = negate(shiftLeft(0x01, n));
        return a & mask;
    }
    

	
}

