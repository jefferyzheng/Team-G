/*作业请提交在这个目录下*/
pragma solidity ^0.4.14;
  contract Payroll {
      /*定义变量*/
      address company;
      address employee;
      uint salary;
      uint constant payPuration=60 seconds;
      uint lastPayday;
      
      //合约调用者
      function Payroll() {
          company=msg.sender;
      }
      
      //更新员工信息
      function updateEmployeeinfo(address e,uint s){
          require(msg.sender==company);
          
          if(employee!=0x0){
              uint payment=salary*(now-lastPayday)/payPuration;
              lastPayday=now;
              employee.transfer(payment);
          }
          
          employee=e;
          salary=s * 1 ether;
          
      }
      
      //公司资金账户
      function companyFund() payable returns(uint) {
          return this.balance;
      }
      
      //公司支付能力次数
      function calculateRunway() returns(uint) {
          return this.balance/salary;
      }
      
      //判断公司是够有支付能力
      function hasEnoughFund() returns(bool){
          return calculateRunway()>0;
      }
      
      //更新下次发薪日，发放本次薪资
      function getPaid(){
          require(msg.sender==employee);
          
          uint nextPayday=lastPayday+payPuration;
          if(nextPayday>now){
              revert();
          }
          
          lastPayday=nextPayday;
          employee.transfer(salary);
      }
      
  }
