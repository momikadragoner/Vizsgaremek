import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { faHourglassEnd } from '@fortawesome/free-solid-svg-icons';
import { AuthService } from '../account-forms/services/auth.service';

export interface Address {
    addressId: number,
    userId: number,
    userFirstName: string,
    userLastName: string,
    phone?: string,
    email: string,
    addressName: string,
    country: string,
    postalCode: string,
    region: string,
    city: string,
    streetAddress: string
}

export class Address {
    /**
     *
     */
    constructor(
        public addressId: number = 0,
        public userId: number = 0,
        public userFirstName: string = '',
        public userLastName: string = '',
        public phone?: string,
        public email: string = '',
        public addressName: string = '',
        public country: string = '',
        public postalCode: string = '',
        public region: string = '',
        public city: string = '',
        public streetAddress: string = ''
    ) {
    }
}

export class City {
    constructor(
        public city: string ='',
        public region: string =''
    ) {

    }
}

@Injectable()
export class AddressService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
    ) { }

    currentUserId = this.authService.getUserDetails()[0].member_id;
    rootURL = '/api';

    getAddress() {
        return this.http.get<[Address]>(this.rootURL + '/address/' + this.currentUserId,
        { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.authService.getToken()}` })})
            .pipe(
                catchError(this.handleError)
            );
    }

    postAddress(address: Address) {
        return this.http.post<object>(this.rootURL + '/address', address,
        { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.authService.getToken()}` })})
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    postAddressToCart(address: Address) {
        return this.http.post<object>(this.rootURL + '/address-to-cart', address, )
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    deleteAddress(id: number) {
        return this.http.delete(this.rootURL + '/address/' + id,
        { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.authService.getToken()}` })})
            .pipe(
                catchError(this.handleError)
            );
    }

    updateAddress(address: Address) {
        return this.http.put(this.rootURL + '/address', address,
        { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.authService.getToken()}` })})
            .pipe(
                catchError(this.handleError)
            );
    }

    getCityByPostalCode(postalCode: number) {
        return this.http.get<City>(this.rootURL + '/city-by-code/' + postalCode,
        { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${this.authService.getToken()}` })})
            .pipe(
                catchError(this.handleError)
            );
    }

    private handleError(error: HttpErrorResponse) {
        if (error.status === 0) {
            console.error('An error occurred:', error.error);
        } else {
            console.error(
                `Backend returned code ${error.status}, body was: `, error.error);
        }
        return throwError(() =>
            'Something bad happened; please try again later.');
    }

}
