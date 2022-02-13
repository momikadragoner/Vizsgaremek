import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

export interface User{
    userId: number,
    firstName: string,
    lastName: string,
    following: number,
    followers: number,
    email: string,
    phone: string,
    about: string,
    profileImgUrl: string,
    headerImgUrl: string,
    registeredAt: Date,
    isVendor: boolean,
    isAdmin: boolean,
    companyName?: string,
    siteLocation?: string,
    website?: string,
    takesCustomOrders?: boolean,
}

export interface UserShort{
  userId: number,
  firstName: string,
  lastName: string,
  about: string,
  profileImgUrl: string,
  companyName?: string,
  takesCustomOrders?: boolean,
}

@Injectable()
export class UserService {

  constructor(private http: HttpClient) { }

  rootURL = '/api';

  getUserShort(id:any) {
    return this.http.get<UserShort>(this.rootURL + '/user-short/' + id,);
  }

  getUser(id:any) {
    return this.http.get<User>(this.rootURL + '/user/' + id,);
  }
  
}

export class User{
    /**
     *
     */
    constructor(
        public userId: number = 0,
        public firstName: string = '',
        public lastName: string = '',
        public following: number = -1,
        public followers: number = -1,
        public email: string = '',
        public phone: string ='',
        public about: string = '',
        public profileImgUrl: string = '',
        public headerImgUrl: string = '',
        public registeredAt: Date = new Date(),
        public isVendor: boolean = false,
        public isAdmin: boolean = false,
        public companyName?: string,
        public siteLocation?: string,
        public website?: string,
        public takesCustomOrders?: boolean,
        ) 
    {
    }
   
}

export const seller = new User( 
    1, 
    "Nagy", "Erzsébet", 
    16, 54, 
    "erzsi.nagy@mail.hu", 
    "301234567", 
    "Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎",
    "assets/profilepic.jpg",
    "assets/header2.jpg",
    new Date(2021, 11, 2),
    true,
    false,
    undefined,
    "Nagybajcs",
    "erzsiekszer.hu",
    true 
)