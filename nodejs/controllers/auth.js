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
                const sql =`insert into member (last_name, first_name, email, password, profile_picture_link, header_picture_link, registered_at) values(?,?,?,?,?,?,?)`
                conn.query(sql,[lastName, firstName, email, hashed_password, "assets/def-pfp1.png", "assets/default_assets/def-bg3.png", new Date()],(err,result, fields)=>{
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

exports.userSignupAsVendor=(req,res,next)=>{
    conn = connectDb();
    try{
        let{lastName, firstName, email, password}=req.body;
        const hashed_password=md5(password.toString())
        const checkEmail =`select email from member where email=?`;
        conn.query(checkEmail,[email],(err,result, fields)=>{
            if(!result.length){
                const sql =`insert into member (last_name, first_name, email, password, profile_picture_link, header_picture_link, registered_at, is_vendor) values(?,?,?,?,?,?,?,?)`
                conn.query(sql,[lastName, firstName, email, hashed_password, "assets/def-pfp1.png", "assets/default_assets/def-bg3.png", new Date(),1],(err,result, fields)=>{
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
                    if (err) console.log("Query " + err)
                })
            }
        })
    } catch(error){
        res.send({status:0, error:error});
    }
}