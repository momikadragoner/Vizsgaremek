import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { Auth } from './auth';

export interface Address {
    addressId: number,
    userId: number,
    userFirstName: string,
    userLastName: string,
    phone?: string,
    email: string,
    addressname: string,
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
        public addressname: string = '',
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

    constructor(private http: HttpClient) { }

    currentUser = Auth.currentUser;

    rootURL = '/api';

    httpOptions = {
        headers: new HttpHeaders({
            'Content-Type': 'application/json',
        })
    };

    getAddress() {
        return this.http.get<[Address]>(this.rootURL + '/address/' + this.currentUser.userId,)
            .pipe(
                catchError(this.handleError)
            );
    }

    postAddress(address: Address) {
        return this.http.post<object>(this.rootURL + '/post-address', address)
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    deleteAddress(id: number) {
        return this.http.delete(this.rootURL + '/delete-address/' + id)
            .pipe(
                catchError(this.handleError)
            );
    }

    getCityByPostalCode(postalCode: number) {
        return this.http.get<City>(this.rootURL + '/city-by-code/' + postalCode)
            .pipe(
                catchError(this.handleError)
            );
    }

    private handleError(error: HttpErrorResponse) {
        if (error.status === 0) {
            // A client-side or network error occurred. Handle it accordingly.
            console.error('An error occurred:', error.error);
        } else {
            // The backend returned an unsuccessful response code.
            // The response body may contain clues as to what went wrong.
            console.error(
                `Backend returned code ${error.status}, body was: `, error.error);
        }
        // Return an observable with a user-facing error message.
        return throwError(() =>
            'Something bad happened; please try again later.');
    }

}