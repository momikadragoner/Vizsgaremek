export class Auth {
    public static currentUser: Auth = new Auth(21, 'nagyeva@mail.hu', 'Nagy', 'Éva', '');
    /**
     *
     */
    constructor(
        public userId: number,
        public email: string,
        public lastName: string,
        public firstName: string,
        public token: string
    ) {  }
}
