// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


contract Terms {
    error Forbidden();

    enum TermEnd {
        Short,
        Medium,
        Long
    }

    mapping(TermEnd => uint256) public terms;

    address public admin;

    constructor(address admin_) {
        admin = admin_;
    }

    function setNewTerm(uint256 newTerm) public {
        if (msg.sender != admin) revert Forbidden();
        terms[TermEnd.Short] = terms[TermEnd.Medium];
        terms[TermEnd.Medium] = terms[TermEnd.Long];
        terms[TermEnd.Long] = newTerm;
    }
}