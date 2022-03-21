const express = require('express');
const app = express();
const bodyParser = require("body-parser");
const db = require('../util/connect-db')
const connectDb = db.connectDb;

const md5=require('md5');
const jwt=require('jsonwebtoken');


app.use(bodyParser.json());

exports.userSignup=(req,res,next)=>{
    conn = connectDb();
    try{
        let{lastName, firstName, email, password}=req.body;
        const hashed_password=md5(password.toString())
        const checkEmail =`select email from member where email=?`;
        conn.query(checkEmail,[email],(err,result, fields)=>{
            if(!result.length){
                const sql =`insert into member (last_name, first_name, email, password) values(?,?,?,?)`
                conn.query(sql,[lastName, firstName, email, hashed_password],(err,result, fields)=>{
                    if(err){
                        res.send({status:0, data:err});
                    } else{
                        let token = jwt.sign({data:result},'secret')
                        res.send({status:1,data:result,token:token});
                    }
                })
            }
        });
    } catch(error){
        res.send({status:0,error:error});
    }
}

exports.userLogin=(req,res,next)=>{
    conn = connectDb();
    try{
        let{userEmail, userPassword}=req.body;
        const hashed_password=md5(userPassword.toString())
        const sql=`select * from member where email=? and password=?`
        conn.query(sql,[userEmail, hashed_password], function(err, result,fields){
            if(!result.length){
                res.send({status:0, data:err});
            } else{
                let token = jwt.sign({data:result}, 'secret')
                res.send({status:1, data:result, token:token})
                conn.query('CALL beginSession(?, ?)', 
                [userEmail, token], function(err, result,fields){
                    if (err) res.json({'message':"Query " + err})
                })
            }
        })
    } catch(error){
        res.send({status:0, error:error});
    }
}