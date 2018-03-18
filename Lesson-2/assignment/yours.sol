pragma solidity ^0.4.14;
contract Payroll{
    /*变量定义*/
    uint constant payDuration=10 seconds;
    address owner;
    uint total;
    
    //结构体
    struct Employee{
        address id;
        uint salary;
        uint lastPayday;
    }
    Employee[] employees;
    
    function Payroll(){
        owner=msg.sender;
    }
    
    //结算之前薪资
    function _partialPaid(Employee employee) private {
        uint payment=employee.salary*(now -employee.lastPayday)/payDuration;
        employee.id.transfer(payment);
    }
    //判断员工是否存在
    function _findEmployee(address employeeid) private returns(Employee,uint){
        for(uint i =0;i<employees.length;i++){
            if(employees[i].id==employeeid){
                return (employees[i],i);
            }
        }
    }
    //添加员工
    function addEmployee(address employeeid,uint salary){
        require(msg.sender==owner);
        var (employee,index)=_findEmployee(employeeid);
        assert(employee.id==0x0);
        
        employees.push(Employee(employeeid,salary * 1 ether,now));
        total+=salary * 1 ether;
    }
    //删除员工
    function removeEmployee(address employeeid){
        require(msg.sender==owner);
        var (employee,index)=_findEmployee(employeeid);
        assert(employee.id!=0x0);
        
        _partialPaid(employee);
        delete employees[index];
        employees[index]=employees[employees.length-1];
        employees.length-=1;
        total-=employees[index].salary;
    }
    //更新员工信息
    function updateEmployee(address employeeid,uint salary){
        require(msg.sender==owner);
        var (employee,index)=_findEmployee(employeeid);
        
        _partialPaid(employee);
        total-=employees[index].salary;
        employees[index].salary=salary * 1 ether;
        total+=employees[index].salary;
        employees[index].lastPayday=now;
    }
    //充值
    function addFund() payable returns(uint){
        return this.balance;
    }
    //计算可支付次数
    function calculateRunway() returns (uint){
        uint totalsalary=0;
        for(uint i =0;i<employees.length;i++){
            totalsalary+=employees[i].salary;
        }
        return this.balance/totalsalary;
    }
    //优化：可支付次数
    function calculateRunwayPlus() returns (uint){
        return this.balance/total;
    }
    //判断是否足够支付
    function hasEnoughFund() returns(bool){
        return calculateRunway()>0;
    }
    //领取薪水
    function getPaid(){
        
        var (employee,index)=_findEmployee(msg.sender);
        assert(employee.id!=0x0);
        
        uint nextPayday=employee.lastPayday+payDuration;
        employees[index].lastPayday=nextPayday;
        employee.id.transfer(employee.salary);
    }
}

/*
加入十个员工消耗gas：
1694 gas
2475 gas
3256 gas
4037 gas
4818 gas
5599 gas
6380 gas
7161 gas
7942 gas
8723 gas

在于每加入一个员工，调用calculateRunway重新遍历统计totalsalary，可在addEmployee和removeEmployee时计算好total金额，
添加calculateRunwayPlus直接使用total计算，调用calculateRunwayPlus发现每次是962 gas
*/
