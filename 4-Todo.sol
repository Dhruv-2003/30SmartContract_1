// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*Todos List 
- add tasks 
- fetch the tasks
- Remove on the completion*/

contract Todo1{
    address public owner;
    uint public taskNo ;
    mapping(uint => string) public Tasks ;
    mapping(uint => bool) public completedTask;
    event taskAdded(string task) ;
    event taskCompleted(string task);

    constructor() {
        owner = msg.sender ; 
    }

    modifier onlyOwner() {
        require(msg.sender==owner, "caller is not owner") ;
        _; 
    } 

    // calldata instead of memory will save gas ,fetching from memory , requires more gas
    function addTask(string calldata _task, uint _taskNo) public onlyOwner {
        taskNo = _taskNo ;
        Tasks[taskNo] = _task ;
        completedTask[taskNo] = false ;
        emit taskAdded(_task);
    }

    function completeTask(uint _taskNo ) public onlyOwner {
        taskNo = _taskNo ;
        completedTask[taskNo] = true ;
        string memory task_ = Tasks[taskNo] ;
        emit taskCompleted(task_);
    }

    function getTask(uint _taskNo) public view returns(string memory task){
        return Tasks[_taskNo] ;
    }
}


/// another similar contract
contract Todo2{
    /// making a todostruct with the required dataset
    struct Todo {
        string task ;
        bool completed ;
    }

    /// declaring events for good user experience
    event taskAdded(string task) ;
    event taskCompleted(string task);
    event updateTask(uint index, string task);

    /// delaring a array containing multiple TodoStruct
    Todo[] public todos ;

    function create(string calldata _task) external {
        todos.push(Todo({
            task: _task,
            completed: false
        })) ;
        emit taskAdded(_task); 
    } 

    function complete(uint _index ) external {
        /// this method might fetch more gas as we have to do 2 operation,
        /// but to access multipe variable in a single todos
        Todo memory todo = todos[_index] ;
        todo.completed = true ;
        emit taskCompleted(todo.task) ;
    }

    function update(uint _index, string calldata _task) external{
        /// this fetch
        todos[_index].task = _task ;
        emit updateTask(_index, _task);
    }

    function get(uint _index) external view returns(string memory ,bool){
        Todo memory todo = todos[_index] ;
        return (todo.task , todo.completed) ; 
    }


}
