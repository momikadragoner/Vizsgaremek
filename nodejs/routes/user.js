const express=require('express');
const router=express.Router();
const md5=require('md5');
const jwt=require('jsonwebtoken');
const mysql=require('mysql');

const con = mysql.createConnection({
    host:"localhost",
    user:"root",
    password:"",
    database:"agora-webshop"
});

router.post('/signup', async function(req,res,next)
{
    try{
        let{lastName, firstName, email, password}=req.body;
        const hashed_password=md5(password.toString())
        const checkEmail =`select email from member where email=?`;
        con.query(checkEmail,[email],(err,result, fields)=>{
            if(!result.length){
                const sql =`insert into member (last_name, first_name, email, password) values(?,?,?,?)`
                con.query(sql,[lastName, firstName, email, hashed_password],(err,result, fields)=>{
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
});



router.post('/login', async function(req,res,next){
    try{
        let{userEmail, userPassword}=req.body;
        const hashed_password=md5(userPassword.toString())
        const sql=`select * from member where email=? and password=?`
        con.query(sql,[userEmail, hashed_password], function(err, result,fields){
            if(!result.length){
                res.send({status:0, data:err});
            } else{
                
                let token = jwt.sign({data:result}, 'secret')
                res.send({status:1, data:result, token:token})
            }
        })
    } catch(error){
        res.send({status:0, error:error});
    }
});




module.exports=router;